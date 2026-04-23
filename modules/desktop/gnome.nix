{ config, pkgs, lib, ... }:

let
  cfg = config.tags;
in
{
  config = lib.mkIf (builtins.elem "gnome" cfg) {
    services.xserver.enable = true;
    services.displayManager.gdm.enable = true;
    services.desktopManager.gnome.enable = true;

    services.displayManager.gdm.wayland = true;

    environment.systemPackages = with pkgs; [
      gnome-tweaks
    ];

    environment.gnome.excludePackages = [
      pkgs.epiphany
    ];

    programs.dconf.enable = true;
  };
}
