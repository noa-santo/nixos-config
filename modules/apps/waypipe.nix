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

    mkdir -p "$REMOTE_MOUNT_DIR" 2>/dev/null
    if ! cd "$REMOTE_MOUNT_DIR" 2>/dev/null; then
      fusermount3 -uz "$REMOTE_MOUNT_DIR" 2>/dev/null || fusermount -uz "$REMOTE_MOUNT_DIR" 2>/dev/null || umount -l "$REMOTE_MOUNT_DIR" 2>/dev/null
      rmdir "$REMOTE_MOUNT_DIR" 2>/dev/null
      mkdir -p "$REMOTE_MOUNT_DIR" || exit 1
    else
      cd - >/dev/null
    fi

    if ! command -v sshfs >/dev/null 2>&1; then
      echo "Error: sshfs is not installed on the remote server." >&2
      exit 127
    fi
    if ! command -v bwrap >/dev/null 2>&1; then
      echo "Error: bubblewrap (bwrap) is not installed on the remote server." >&2
      exit 127
    fi

    echo "Waiting for reverse SSH tunnel bridge..."
    RETRIES=10
    while ! nc -z 127.0.0.1 2222 2>/dev/null && [ $RETRIES -gt 0 ]; do
      sleep 0.5
      RETRIES=$((RETRIES - 1))
    done

    if [ $RETRIES -eq 0 ]; then
      echo "Error: Reverse SSH tunnel port 2222 is not accessible." >&2
      exit 1
    fi

    sshfs -p 2222 -o reconnect,StrictHostKeyChecking=no,allow_other,default_permissions,uid=$(id -u),gid=$(id -g) "''${LOCAL_USER}@localhost:''${LOCAL_HOME}" "$REMOTE_MOUNT_DIR" || exit 1

    mkdir -p "$REMOTE_MOUNT_DIR/.local/state" || exit 1

    REMOTE_BASH="$(command -v bash || echo /run/current-system/sw/bin/bash)"

    BWRAP_ARGS=(
      --dev-bind / /
      --dev-bind /run/user /run/user
      --bind "$REMOTE_MOUNT_DIR" "$HOME"
      --ro-bind /nix /nix
      --ro-bind /etc/profiles /etc/profiles
      --ro-bind /run/current-system /run/current-system
      --ro-bind /etc/ssl /etc/ssl
      --chdir "$HOME"
      --setenv HOME "$HOME"
      --setenv XDG_CONFIG_HOME "$HOME/.config"
      --setenv XDG_DATA_HOME "$HOME/.local/share"
      --setenv XDG_CACHE_HOME "$HOME/.cache"
      --setenv WAYLAND_DISPLAY "$WAYLAND_DISPLAY"
      --setenv XDG_RUNTIME_DIR "$XDG_RUNTIME_DIR"
    )

    if [ -e /run/opengl-driver ]; then
      BWRAP_ARGS+=(--ro-bind /run/opengl-driver /run/opengl-driver)
    fi

    if [ -e "$HOME/.nix-profile" ]; then
      NIX_PROFILE_TARGET="$(readlink -f "$HOME/.nix-profile")"
      if [ -e "$NIX_PROFILE_TARGET" ]; then
        BWRAP_ARGS+=(--ro-bind "$NIX_PROFILE_TARGET" "$HOME/.nix-profile")
      fi
    fi

    if [ -e "$HOME/.local/state" ]; then
      BWRAP_ARGS+=(--bind "$HOME/.local/state" "$HOME/.local/state")
    fi

    exec bwrap "''${BWRAP_ARGS[@]}" "$REMOTE_BASH" -c 'exec "$@"' -- "$@"
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
        TARGET_HOST=""
        TARGET_USER=""

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

          ssh "$SSH_TARGET" "fusermount3 -u $REMOTE_MOUNT_DIR 2>/dev/null; rmdir $REMOTE_MOUNT_DIR 2>/dev/null"

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
    UsePrivilegeSeparation no
    PidFile ''${SSH_DIR}/sshd_temp.pid
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

          ssh "$SSH_TARGET" "fusermount3 -u $REMOTE_MOUNT_DIR 2>/dev/null; rmdir $REMOTE_MOUNT_DIR 2>/dev/null"

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
    pkgs.bubblewrap
    waypipeRunner
  ];

  programs.fuse.userAllowOther = true;
}
