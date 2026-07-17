# tags: sway
{ pkgs, inputs, lib, ... }:
{
  hardware.graphics.enable = true;
  services.displayManager.gdm.enable = true;
  programs.sway.enable = true;
}
