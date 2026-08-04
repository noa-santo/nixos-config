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

      echo "Setting up reverse file bridge at $REMOTE_MOUNT_DIR..."

      CMD_STR=""
      for arg in "$@"; do
        printf -v escaped '%q' "$arg"
        CMD_STR="$CMD_STR $escaped"
      done

      REMOTE_SCRIPT="
        mkdir -p $REMOTE_MOUNT_DIR || exit 1
        if ! command -v sshfs >/dev/null 2>&1; then
          echo 'Error: sshfs is not installed on the remote server.' >&2
          exit 127
        fi
        sshfs -p 2222 -o reconnect,StrictHostKeyChecking=no $LOCAL_USER@localhost:$HOME $REMOTE_MOUNT_DIR || {
          echo 'Error: sshfs failed to mount local filesystem. Check SSH agent forwarding and local sshd.' >&2
          exit 1
        }
        exec $CMD_STR
      "
      B64_SCRIPT=$(echo -n "$REMOTE_SCRIPT" | base64 -w 0)

      ${pkgs.waypipe}/bin/waypipe ssh -A -R 2222:127.0.0.1:22 "$SSH_TARGET" bash -c "echo $B64_SCRIPT | base64 -d | bash"

      echo "Cleaning up remote file bridge..."
      ssh "$SSH_TARGET" "fusermount3 -u $REMOTE_MOUNT_DIR 2>/dev/null; rmdir $REMOTE_MOUNT_DIR 2>/dev/null"
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
    waypipeRunner
  ];
}
