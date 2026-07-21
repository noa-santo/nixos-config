{ pkgs, ... }:
{
  environment.shellAliases = {
    rebuild = "sudo nixos-rebuild switch --flake $HOME/.config/nixos-config#$(hostname)";
    rebuild-fast = "sudo nixos-rebuild switch --flake $HOME/.config/nixos-config#$(hostname) --option substituters 'https://cache.nixos.org https://nix-community.cachix.org https://niri-epireyn.cachix.org' --option trusted-public-keys 'cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs= niri-epireyn.cachix.org-1:tlVyFN7CtsDT+ZcLPS+ekFWeT1X6X4OqvWqbBMyIzFA='";
    update = "sudo nix flake update --flake $HOME/.config/nixos-config";
  };

  environment.systemPackages = with pkgs; [
    (pkgs.writeShellScriptBin "rebuild-reboot" ''
      sudo nixos-rebuild boot --flake $HOME/.config/nixos-config#$(hostname)
      if [ $? -eq 0 ]; then
       read -p "Nixos rebuild successful. Reboot now? (y/N) " response
       if [[ "$response" = "y" || "$response" = "Y" ]]; then
        sudo reboot
       fi
      fi
    '')
    (pkgs.writeShellScriptBin "tmp" ''
      if [ "$#" -lt 1 ]; then
        echo "usage: tmp <package> [args...]" >&2
        exit 2
      fi
      pkg="$1"
      shift

      nix shell "nixpkgs#''${pkg}" --command "''${pkg}" "$@" 2>/tmp/tmp-error-$$.log
      rc=$?

      if [ $rc -eq 0 ]; then
        exit 0
      fi

      if grep -qiE "unfree|not allowed|non-free|license" /tmp/tmp-error-$$.log; then
        echo "Attempting with NIXPKGS_ALLOW_UNFREE=1..." >&2
        rm -f /tmp/tmp-error-$$.log
        NIXPKGS_ALLOW_UNFREE=1 nix shell --impure "nixpkgs#''${pkg}" --command "''${pkg}" "$@"
        exit $?
      fi

      cat /tmp/tmp-error-$$.log >&2
      rm -f /tmp/tmp-error-$$.log
      exit $rc
    '')
    (pkgs.writeShellScriptBin "cleanup" ''
      count=30
      unit="d"

      if [ "$#" -eq 2 ]; then
        count=$1
        case $2 in
          day*)    unit="d" ;;
          week*)   unit="d"; count=$((count * 7)) ;;
          month*)  unit="d"; count=$((count * 30)) ;;
          year*)   unit="d"; count=$((count * 365)) ;;
          *) echo "Invalid unit. Use day, week, month, or year."; exit 1 ;;
        esac
      elif [ "$#" -eq 1 ]; then
        case $1 in
          day*)    count=1; unit="d" ;;
          week*)   count=7; unit="d" ;;
          month*)  count=30; unit="d" ;;
          year*)   count=365; unit="d" ;;
          *) echo "Usage: cleanup [number] [day|week|month|year]"; exit 1 ;;
        esac
      fi

      echo "Cleaning up generations older than $count days..."
      sudo nix-collect-garbage --delete-older-than "$count$unit" && sudo nixos-rebuild boot --flake $HOME/.config/nixos-config#$(hostname)
    '')
  ];

  programs.fish.enable = true;
}
