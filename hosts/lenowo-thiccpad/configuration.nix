{ ... }:
{
  imports = [
    ../../modules/all.nix
  ];

  mainUser = "owo";
  networking.hostName = "lenowo-thiccpad";
  styling.name = "vibrant-wave";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.xserver.xkb = {
    layout = "us";
    variant = "altgr-intl";
  };

  security.pam.services.login.enableGnomeKeyring = true;
  security.pam.services.gdm-password.enableGnomeKeyring = true;

  system.stateVersion = "26.05";
}
