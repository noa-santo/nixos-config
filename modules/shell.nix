{pkgs, ...}:
{
 environment.shellAliases = {
  rebuild = "sudo nixos-rebuild switch --flake $HOME/.config/nixos-config#$(hostname)";
  rebuild-fast = "sudo nixos-rebuild switch --flake $HOME/.config/nixos-config#$(hostname) --option substituters 'https://cache.nixos.org https://nix-community.cachix.org' --option trusted-public-keys 'cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURgN8cP5tPgkpXYAOGOBo= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs='";
  rebuild-boot = "sudo nixos-rebuild boot --flake $HOME/.config/nixos-config#$(hostname)";
  update = "sudo nix flake update --flake $HOME/.config/nixos-config";
 };
 programs.fish.enable = true;
}
