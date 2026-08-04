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
      echo "usage: remote-run [user@host|host] <command> [args...]" >&2
      exit 1
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

    echo "Running '$*' on $SSH_TARGET via waypipe..."
    exec ${pkgs.waypipe}/bin/waypipe ssh "$SSH_TARGET" "$@"
  '';
in
{
  environment.systemPackages = [
    pkgs.waypipe
    waypipeRunner
  ];
}
