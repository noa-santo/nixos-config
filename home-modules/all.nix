# dont add stuff directly in here. only import
{ pkgs, inputs, ... }:
{
  imports = [
    ./desktop/gnome.nix
    ./desktop/sway.nix
    ./desktop/waybar/waybar.nix
    ./desktop/cava.nix
    ./desktop/easyeffects.nix
    ./desktop/vicinae.nix
    ./theming/matugen.nix
    ./theming/gtk.nix
    ./git.nix
    ./shell/all.nix
    ./dev.nix
    ./browser.nix
  ];
}
