{pkgs, ...}:
{
 environment.shellAliases = {
  rebuild = "sudo nixos-rebuild switch --flake $HOME/.config/nixos-config#$(hostname)";
  rebuild-fast = "sudo nixos-rebuild switch --flake $HOME/.config/nixos-config#$(hostname) --option substituters 'https://cache.nixos.org https://nix-community.cachix.org' --option trusted-public-keys 'cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs='";
  update = "sudo nix flake update --flake $HOME/.config/nixos-config";
  # TODO: cleanup command that deletes unused stuff and old config backups
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
       NIXPKGS_ALLOW_UNFREE=1 nix shell "nixpkgs#''${pkg}" --command "''${pkg}" "$@"
       exit $?
     fi

     cat /tmp/tmp-error-$$.log >&2
     rm -f /tmp/tmp-error-$$.log
     exit $rc
    ''
    )
  ];

  programs.fish.enable = true;
}
