{pkgs, ...}:
{
 environment.shellAliases = {
  rebuild = "sudo nixos-rebuild switch --flake $HOME/.config/nixos-config#$(hostname)";
  update = "sudo nix flake update --flake $HOME/.config/nixos-config";
 };
 programs.fish.enable = true;
}
