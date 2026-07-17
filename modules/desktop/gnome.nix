# tags: gnome
{ config, pkgs, lib, ... }:
{
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  services.gnome.gnome-keyring.enable = true;

  environment.systemPackages = with pkgs; [
    gnome-tweaks
  ];

  environment.gnome.excludePackages = [
    pkgs.epiphany
  ];

  programs.dconf.enable = true;
}
