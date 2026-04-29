{ config, pkgs, ... }:
{
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  services.displayManager.gdm.wayland = true;

  environment.systemPackages = with pkgs; [
    gnome-tweaks
  ];

  programs.dconf.enable = true;
}
