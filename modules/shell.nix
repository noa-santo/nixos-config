{pkgs, ...}:
{
 environment.shellAliases = {
  rebuild = "sudo nixos-rebuild switch --flake $HOME/.config/nixos-config#$(hostname)";
  rebuild-fast = "sudo nixos-rebuild switch --flake $HOME/.config/nixos-config#$(hostname) --option substituters 'https://cache.nixos.org https://nix-community.cachix.org' --option trusted-public-keys 'cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURgN8cP5tPgkpXYAOGOBo= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs='";
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
  ];

  programs.fish.enable = true;
}
