{ ... }:
{
  imports = [
    ../../modules/all.nix
  ];

  mainUser = "owo";
  networking.hostName = "dell";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.xserver.xkb = {
    layout = "us";
    variant = "altgr-intl";
  };

  security.pam.services.login.enableGnomeKeyring = true;
  security.pam.services.gdm-password.enableGnomeKeyring = true;

  networking.firewall.allowedTCPPorts = [ 8080 ];

  system.stateVersion = "25.11";
}
