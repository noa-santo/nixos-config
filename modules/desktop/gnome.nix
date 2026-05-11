{ config, pkgs, lib, ... }:

let
  cfg = config.tags;
in
{
  config = lib.mkIf (builtins.elem "gnome" cfg) {
    services.displayManager.gdm.enable = true;
    services.desktopManager.gnome.enable = true;
    services.displayManager.gdm.wayland = true;
    services.gnome.gnome-keyring.enable = true;

    environment.systemPackages = with pkgs; [
      gnome-tweaks
    ];

    environment.gnome.excludePackages = [
      pkgs.epiphany
    ];

    programs.dconf.enable = true;
  };
}
