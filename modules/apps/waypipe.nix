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

    exec env HOME="$REMOTE_MOUNT_DIR" \
      XDG_CONFIG_HOME="$REMOTE_MOUNT_DIR/.config" \
      XDG_DATA_HOME="$REMOTE_MOUNT_DIR/.local/share" \
      XDG_STATE_HOME="$REMOTE_MOUNT_DIR/.local/state" \
      XDG_CACHE_HOME="$REMOTE_MOUNT_DIR/.cache" \
      "$@"
  '';

  waypipeRunner = pkgs.writeShellScriptBin "remote-run" ''
        if [ "$#" -lt 1 ]; then
          exit 1
        fi

        ENABLE_MOUNT=0
        if [ "$1" = "-m" ] || [ "$1" = "--mount" ]; then
          ENABLE_MOUNT=1
          shift
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

          for host in "''${VALID_HOSTS[@]}"; do
            user="''${HOST_USERS[$host]}"
            if ssh -o ConnectTimeout=2 -o BatchMode=yes "''${user}@''${host}" true 2>/dev/null; then
              TARGET_HOST="$host"
              TARGET_USER="$user"
              break
            fi
          done
        fi

        if [ -z "$TARGET_HOST" ]; then
          exit 1
        fi

        SSH_TARGET="$TARGET_HOST"
        if [ -n "$TARGET_USER" ]; then
          SSH_TARGET="''${TARGET_USER}@''${TARGET_HOST}"
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

          ${pkgs.waypipe}/bin/waypipe ssh -A -R 2222:127.0.0.1:2222 "$SSH_TARGET" \
            bash -s -- "$REMOTE_MOUNT_DIR" "$LOCAL_USER" "$HOME" "$@" < ${remoteMountScript}

          ssh "$SSH_TARGET" "fusermount3 -u $REMOTE_MOUNT_DIR 2>/dev/null; rmdir $REMOTE_MOUNT_DIR 2>/dev/null || true"

          if [ "$ADDED_KEY" -eq 1 ]; then
            sed -i "\|$PUB_KEY|d" "$SSH_DIR/authorized_keys"
          fi

          cleanup_local_sshd
          trap - EXIT
        else
          exec ${pkgs.waypipe}/bin/waypipe ssh "$SSH_TARGET" "$@"
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
