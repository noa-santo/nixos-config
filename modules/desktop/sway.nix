{ pkgs, inputs, ... }:
{
  hardware.graphics.enable = true;
  services.displayManager.gdm.enable = true;
  services.displayManager.gdm.wayland = true;
  programs.sway.enable = true;
}
