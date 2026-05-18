{ config, pkgs, lib, ... }:

{
  imports = [
    ../../modules/all.nix
  ];

  mainUser = "owo";
  networking.hostName = "dell";

  tags = [
      "laptop"
      "gnome"
      "sway"
      "dev"
      "docker"
      "gaming"
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.xserver.xkb = {
    layout = "us";
    variant = "altgr-intl";
  };

  security.pam.services.login.enableGnomeKeyring = true;
  security.pam.services.gdm-password.enableGnomeKeyring = true;

  system.stateVersion = "25.11";
}
