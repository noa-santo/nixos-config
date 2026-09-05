# tags: waypipe
{ pkgs, ... }:
let
  hostData =
    pkgs.lib.filterAttrs
      (
        _: data:
        data.mainUser != null && (builtins.elem "waypipe" data.tags) && (builtins.elem "server" data.tags)
      )
      (
        pkgs.lib.genAttrs (builtins.attrNames (builtins.readDir ../../hosts)) (
          host:
          let
            tagsPath = ../../hosts/${host}/tags.nix;
            configPath = ../../hosts/${host}/configuration.nix;

            tags = if builtins.pathExists tagsPath then import tagsPath else [ ];
            configContent = if builtins.pathExists configPath then builtins.readFile configPath else "";
            userMatch = builtins.match ".*mainUser[[:space:]]*=[[:space:]]*\"([^\"]+)\".*" configContent;
            mainUser = if userMatch != null then builtins.elemAt userMatch 0 else null;
          in
          {
            inherit tags mainUser;
          }
        )
      );

  hostUserCases = pkgs.lib.concatStringsSep "\n" (
    pkgs.lib.mapAttrsToList (host: data: "  [${host}]=\"${data.mainUser}\"") hostData
  );

  remoteMountScript = pkgs.writeShellScript "waypipe-remote-mount" ''
    set -e

    REMOTE_MOUNT_DIR="$1"
    LOCAL_USER="$2"
    LOCAL_HOME="$3"
    shift 3

    mkdir -p "$REMOTE_MOUNT_DIR"

    for bin in sshfs nc; do
      command -v "$bin" >/dev/null 2>&1 || exit 127
    done

    echo "Waiting for reverse SSH tunnel bridge..." >&2
    for _ in $(seq 1 20); do
      nc -z 127.0.0.1 2222 2>/dev/null && break
      sleep 0.5
    done
    nc -z 127.0.0.1 2222 2>/dev/null || { echo "Error: tunnel port 2222 inaccessible." >&2; exit 1; }

    sshfs -p 2222 \
      -o reconnect,StrictHostKeyChecking=no,follow_symlinks,allow_other,uid=$(id -u),gid=$(id -g) \
      "''${LOCAL_USER}@localhost:''${LOCAL_HOME}" "$REMOTE_MOUNT_DIR"

    cleanup() {
      fusermount3 -uz "$REMOTE_MOUNT_DIR" 2>/dev/null || true
      rmdir "$REMOTE_MOUNT_DIR" 2>/dev/null || true
    }
    trap cleanup EXIT

    cd "$REMOTE_MOUNT_DIR"

    exec env HOME="$REMOTE_MOUNT_DIR" \
      XDG_CONFIG_HOME="$REMOTE_MOUNT_DIR/.config" \
      XDG_DATA_HOME="$REMOTE_MOUNT_DIR/.local/share" \
      XDG_STATE_HOME="$REMOTE_MOUNT_DIR/.local/state" \
      XDG_CACHE_HOME="$REMOTE_MOUNT_DIR/.cache" \
      "$@"
  '';

  waypipeRunner = pkgs.writeShellScriptBin "remote-run" ''
    ENABLE_MOUNT=0
    OPTIMIZE=0
    TYPE="text"
    ARGS=()

    while [[ "$#" -gt 0 ]]; do
      case "$1" in
        -m|--mount) ENABLE_MOUNT=1; shift ;;
        -o|--optimize) OPTIMIZE=1; shift ;;
        -t|--type) TYPE="$2"; shift 2 ;;
        *) ARGS+=("$1"); shift ;;
      esac
    done

    set -- "''${ARGS[@]}"

        if [ "$#" -lt 1 ]; then
          exit 1
        fi

        CURRENT_HOST="$(hostname)"
        declare -A HOST_USERS=(
        ${hostUserCases}
        )

        is_explicit_address() {
          local arg="$1"
          if [[ "$arg" =~ ^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+$ ]] || \
             [[ "$arg" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]] || \
             [[ -n "''${HOST_USERS[$arg]}" ]]; then
            return 0
          fi
          return 1
        }

        if [ "$#" -ge 2 ] && is_explicit_address "$1"; then
          RAW_TARGET="$1"
          shift
          if [[ "$RAW_TARGET" =~ ^([^@]+)@(.+)$ ]]; then
            TARGET_USER="''${BASH_REMATCH[1]}"
            TARGET_HOST="''${BASH_REMATCH[2]}"
          elif [ -n "''${HOST_USERS[$RAW_TARGET]}" ]; then
            TARGET_USER="''${HOST_USERS[$RAW_TARGET]}"
            TARGET_HOST="$RAW_TARGET"
          else
            TARGET_HOST="$RAW_TARGET"
          fi
        else
          VALID_HOSTS=()
          for h in "''${!HOST_USERS[@]}"; do
            if [ "$h" != "$CURRENT_HOST" ]; then
              VALID_HOSTS+=("$h")
            fi
          done

          if [ ''${#VALID_HOSTS[@]} -eq 0 ]; then
            exit 1
          fi

          BEST_HOST=""
          BEST_USER=""
          MAX_SCORE=""

          for host in "''${VALID_HOSTS[@]}"; do
            user="''${HOST_USERS[$host]}"
            metrics=$(ssh -o ConnectTimeout=2 -o BatchMode=yes "''${user}@''${host}" '
              awk "/MemAvailable/ {avail=\$2} END {print avail}" /proc/meminfo
              awk "{print \$1}" /proc/loadavg
              nproc
            ' 2>/dev/null) || continue

            read -r free_kb load_1 cpu_count <<< "$(echo "$metrics" | tr '\n' ' ')"
            if [ -z "$free_kb" ] || [ -z "$load_1" ] || [ -z "$cpu_count" ]; then
              continue
            fi

            score=$(awk -v ram="$free_kb" -v load_val="$load_1" -v cpus="$cpu_count" 'BEGIN {
              ram_gb = ram / 1024 / 1024
              effective_load = load_val / cpus
              score = ram_gb - (effective_load * 2)
              print score
            }')

            if [ -z "$BEST_HOST" ] || $(awk -v s1="$score" -v s2="$MAX_SCORE" 'BEGIN {exit !(s1 > s2)}'); then
              BEST_HOST="$host"
              BEST_USER="$user"
              MAX_SCORE="$score"
            fi
          done

          TARGET_HOST="$BEST_HOST"
          TARGET_USER="$BEST_USER"
        fi

        if [ -z "$TARGET_HOST" ]; then
          exit 1
        fi

        SSH_TARGET="$TARGET_HOST"
        if [ -n "$TARGET_USER" ]; then
          SSH_TARGET="''${TARGET_USER}@''${TARGET_HOST}"
        fi

        CACHE_DIR="''${XDG_CACHE_HOME:-$HOME/.cache}/waypipe-wrapper"
        mkdir -p "$CACHE_DIR"
        OPTIMAL_FILE="$CACHE_DIR/$TARGET_HOST.optimal"
        BW_CACHE="$CACHE_DIR/$TARGET_HOST.bw"

        clean_bench() {
          sed -nE 's/^([a-zA-Z0-9=-]+):[[:space:]]+text-like \(([0-9.e+-]+)[^,]*,([0-9.e+-]+)[^)]*\)[[:space:]]+bytes\/sec,[[:space:]]+ratio[[:space:]]+([0-9.]+)[[:space:]]+image-like \(([0-9.e+-]+)[^,]*,([0-9.e+-]+)[^)]*\)[[:space:]]+bytes\/sec,[[:space:]]+ratio[[:space:]]+([0-9.]+).*/\1 \2 \3 \4 \5 \6 \7/p'
        }

        if [ "$OPTIMIZE" -eq 1 ]; then
          echo "Running waypipe benchmark on server and client..." >&2
          ssh "$SSH_TARGET" "waypipe bench" | clean_bench > "$CACHE_DIR/$TARGET_HOST.server.raw"
          ${pkgs.waypipe}/bin/waypipe bench | clean_bench > "$CACHE_DIR/$TARGET_HOST.client.raw"

          echo "Benchmark done. Calculating optimal compression algorithms..." >&2

          awk '
          BEGIN {
              split("1e6 2e6 5e6 1e7 2e7 5e7 1e8 2e8 5e8 1e9 2e9 5e9 1e10 2e10", bws, " ")
          }
          NR==FNR {
              s_t_comp[$1] = $2 + 0
              s_i_comp[$1] = $5 + 0
              t_ratio[$1] = $4 + 0
              i_ratio[$1] = $7 + 0
              next
          }
          {
              c_t_decomp[$1] = $3 + 0
              c_i_decomp[$1] = $6 + 0
              algos[++n_algos] = $1
          }
          END {
              for (i=1; i<=length(bws); i++) {
                  bw = bws[i] + 0
                  best_t_algo = "none"; min_t_time = 1e99
                  best_i_algo = "none"; min_i_time = 1e99

                  for (j=1; j<=n_algos; j++) {
                      algo = algos[j]
                      if (s_t_comp[algo] == 0 || c_t_decomp[algo] == 0) continue

                      t_time = (1 / s_t_comp[algo]) + (t_ratio[algo] / bw) + (1 / c_t_decomp[algo])
                      if (t_time < min_t_time) {
                          min_t_time = t_time
                          best_t_algo = algo
                      }

                      i_time = (1 / s_i_comp[algo]) + (i_ratio[algo] / bw) + (1 / c_i_decomp[algo])
                      if (i_time < min_i_time) {
                          min_i_time = i_time
                          best_i_algo = algo
                      }
                  }
                  printf "%.0f %s %s\n", bw, best_t_algo, best_i_algo
              }
          }' "$CACHE_DIR/$TARGET_HOST.server.raw" "$CACHE_DIR/$TARGET_HOST.client.raw" > "$OPTIMAL_FILE"
        fi

        WAYPIPE_EXTRA_ARGS=()
        if [ -f "$OPTIMAL_FILE" ]; then
          BW=""
          if [ -f "$BW_CACHE" ]; then
            BW=$(cat "$BW_CACHE")
          fi

          (
            CACHE_AGE=999999
            if [ -f "$BW_CACHE" ]; then
                CACHE_AGE=$(($(date +%s) - $(stat -c %Y "$BW_CACHE")))
            fi
            if [ "$CACHE_AGE" -gt 300 ]; then
                echo "Run bandwidth test..."
                START=''${EPOCHREALTIME/./}
                ssh -o ConnectTimeout=5 "$SSH_TARGET" "dd if=/dev/zero bs=100K count=20 2>/dev/null" | dd of=/dev/null 2>/dev/null
                END=''${EPOCHREALTIME/./}
                DIFF_US=$(( 10#$END - 10#$START ))
                TRANSFER_US=$(( DIFF_US - 300000 ))
                [ "$TRANSFER_US" -lt 10000 ] && TRANSFER_US=10000
                BPS=$(( 2048000 * 1000000 / TRANSFER_US ))
                echo "$BPS" > "$BW_CACHE.tmp"
                mv "$BW_CACHE.tmp" "$BW_CACHE"
            fi
          ) </dev/null >/dev/null 2>&1 & disown

          if [ -z "$BW" ]; then
            BW=10000000
          fi

          BEST_COMP=$(awk -v bps="$BW" -v type="$TYPE" '
            BEGIN { min_diff = -1; best_algo = "none" }
            {
              diff = $1 - bps
              if (diff < 0) diff = -diff
              if (min_diff == -1 || diff < min_diff) {
                min_diff = diff
                best_algo = (type == "image") ? $3 : $2
              }
            }
            END { print best_algo }
          ' "$OPTIMAL_FILE")

          if [ -n "$BEST_COMP" ] && [ "$BEST_COMP" != "none" ]; then
            WAYPIPE_EXTRA_ARGS=("-c" "$BEST_COMP")
          fi
        fi

        if [ "$ENABLE_MOUNT" -eq 1 ]; then
          LOCAL_USER="$(whoami)"
          REMOTE_MOUNT_DIR="/tmp/local-files-$LOCAL_USER"
          SSH_DIR="$HOME/.ssh"
          HOST_KEY="$SSH_DIR/ssh_host_rsa_key"

      ssh "$SSH_TARGET" "fusermount3 -u $REMOTE_MOUNT_DIR 2>/dev/null; rmdir $REMOTE_MOUNT_DIR 2>/dev/null || true"

          mkdir -p "$SSH_DIR"
          chmod 700 "$SSH_DIR"
          if [ ! -f "$HOST_KEY" ]; then
            ssh-keygen -t rsa -b 2048 -N "" -f "$HOST_KEY" >/dev/null 2>&1
          fi

          CONFIG_FILE="$SSH_DIR/sshd_config_temp"
          cat << EOF > "$CONFIG_FILE"
    Port 2222
    HostKey ''${HOST_KEY}
    AuthorizedKeysFile ''${SSH_DIR}/authorized_keys
    Subsystem sftp ${pkgs.openssh}/libexec/sftp-server
    PidFile ''${SSH_DIR}/sshd_temp.pid
    StrictModes no
    PasswordAuthentication no
    PubkeyAuthentication yes
    EOF

          ${pkgs.openssh}/bin/sshd -f "$CONFIG_FILE"

          cleanup_local_sshd() {
            if [ -f "$SSH_DIR/sshd_temp.pid" ]; then
              kill "$(cat "$SSH_DIR/sshd_temp.pid")" 2>/dev/null || true
            fi
            rm -f "$CONFIG_FILE" "$SSH_DIR/sshd_temp.pid"
          }
          trap cleanup_local_sshd EXIT

          PUB_KEY=""
          if [ -f "$SSH_DIR/id_ed25519.pub" ]; then
            PUB_KEY="$(cat "$SSH_DIR/id_ed25519.pub")"
          elif [ -f "$SSH_DIR/id_rsa.pub" ]; then
            PUB_KEY="$(cat "$SSH_DIR/id_rsa.pub")"
          else
            exit 1
          fi

          touch "$SSH_DIR/authorized_keys"
          chmod 600 "$SSH_DIR/authorized_keys"
          ADDED_KEY=0
          if ! grep -qF "$PUB_KEY" "$SSH_DIR/authorized_keys"; then
            echo "$PUB_KEY" >> "$SSH_DIR/authorized_keys"
            ADDED_KEY=1
          fi

          ${pkgs.waypipe}/bin/waypipe "''${WAYPIPE_EXTRA_ARGS[@]}" ssh -A -R 2222:127.0.0.1:2222 "$SSH_TARGET" \
            bash -s -- "$REMOTE_MOUNT_DIR" "$LOCAL_USER" "$HOME" "$@" < ${remoteMountScript}

          ssh "$SSH_TARGET" "fusermount3 -u $REMOTE_MOUNT_DIR 2>/dev/null; rmdir $REMOTE_MOUNT_DIR 2>/dev/null || true"

          if [ "$ADDED_KEY" -eq 1 ]; then
            sed -i "\|$PUB_KEY|d" "$SSH_DIR/authorized_keys"
          fi

          cleanup_local_sshd
          trap - EXIT
        else
          exec ${pkgs.waypipe}/bin/waypipe "''${WAYPIPE_EXTRA_ARGS[@]}" ssh "$SSH_TARGET" "$@"
        fi
  '';
in
{
  environment.systemPackages = [
    pkgs.waypipe
    pkgs.sshfs
    waypipeRunner
  ];

  programs.fuse.userAllowOther = true;
}
