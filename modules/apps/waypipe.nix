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
    shift 2

    mkdir -p "$REMOTE_MOUNT_DIR" || exit 1
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

    sshfs -p 2222 -o reconnect,StrictHostKeyChecking=no,allow_other "''${LOCAL_USER}@localhost:''${HOME}" "$REMOTE_MOUNT_DIR" || {
      echo "Error: sshfs failed to mount local filesystem." >&2
      exit 1
    }

    REMOTE_BASH="$(command -v bash || echo /run/current-system/sw/bin/bash)"

    BWRAP_ARGS=(
      --unshare-user
      --uid "$(id -u)"
      --gid "$(id -g)"
      --dev-bind / /
      --dev-bind /run/user /run/user
      --bind "$REMOTE_MOUNT_DIR" "$HOME"
      --ro-bind /nix /nix
      --chdir "$HOME"
      --setenv HOME "$HOME"
      --setenv XDG_CONFIG_HOME "$HOME/.config"
      --setenv XDG_DATA_HOME "$HOME/.local/share"
      --setenv XDG_CACHE_HOME "$HOME/.cache"
      --setenv WAYLAND_DISPLAY "$WAYLAND_DISPLAY"
      --setenv XDG_RUNTIME_DIR "$XDG_RUNTIME_DIR"
    )

    if [ -e "/home/$USER/.nix-profile" ]; then
      BWRAP_ARGS+=(--bind "/home/$USER/.nix-profile" "$HOME/.nix-profile")
    fi

    if [ -e "/home/$USER/.local/state" ]; then
      BWRAP_ARGS+=(--bind "/home/$USER/.local/state" "$HOME/.local/state")
    fi

    exec bwrap "''${BWRAP_ARGS[@]}" "$REMOTE_BASH" -c 'exec "$@"' -- "$@"
  '';

  waypipeRunner = pkgs.writeShellScriptBin "remote-run" ''
    if [ "$#" -lt 1 ]; then
      echo "usage: remote-run [-m|--mount] [user@host|host] <command> [args...]" >&2
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
        echo "Error: No remote hosts defined with both 'waypipe' and 'server' tags." >&2
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
      echo "Error: Could not resolve or reach a valid target host." >&2
      exit 1
    fi

    SSH_TARGET="$TARGET_HOST"
    if [ -n "$TARGET_USER" ]; then
      SSH_TARGET="''${TARGET_USER}@''${TARGET_HOST}"
    fi

    if [ "$ENABLE_MOUNT" -eq 1 ]; then
      LOCAL_USER="$(whoami)"
      REMOTE_MOUNT_DIR="/tmp/local-files-$LOCAL_USER"

      # Pre-run cleanup guard for stale mounts
      ssh "$SSH_TARGET" "fusermount3 -u $REMOTE_MOUNT_DIR 2>/dev/null; rmdir $REMOTE_MOUNT_DIR 2>/dev/null"

      echo "Setting up automated local loopback authorization..."
      mkdir -p ~/.ssh
      if [ -f ~/.ssh/id_ed25519.pub ]; then
        PUB_KEY="$(cat ~/.ssh/id_ed25519.pub)"
      elif [ -f ~/.ssh/id_rsa.pub ]; then
        PUB_KEY="$(cat ~/.ssh/id_rsa.pub)"
      else
        echo "Error: No local SSH public key found in ~/.ssh/" >&2
        exit 1
      fi

      touch ~/.ssh/authorized_keys
      chmod 600 ~/.ssh/authorized_keys
      if ! grep -qF "$PUB_KEY" ~/.ssh/authorized_keys; then
        echo "Setting up automated local loopback authorization..."
        echo "$PUB_KEY" >> ~/.ssh/authorized_keys
        ADDED_KEY=1
      else
        ADDED_KEY=0
      fi

      echo "Setting up reverse file bridge at $REMOTE_MOUNT_DIR..."

      ${pkgs.waypipe}/bin/waypipe ssh -A -R 2222:127.0.0.1:22 "$SSH_TARGET" \
        bash -s -- "$REMOTE_MOUNT_DIR" "$LOCAL_USER" "$@" < ${remoteMountScript}

      echo "Cleaning up remote file bridge..."
      ssh "$SSH_TARGET" "fusermount3 -u $REMOTE_MOUNT_DIR 2>/dev/null; rmdir $REMOTE_MOUNT_DIR 2>/dev/null"

      if [ "$ADDED_KEY" -eq 1 ]; then
        sed -i "\|$PUB_KEY|d" ~/.ssh/authorized_keys
      fi
    else
      echo "Running '$*' on $SSH_TARGET via waypipe..."
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
