{ pkgs, ... }:
{
  imports = [
    ../../modules/all.nix
  ];

  mainUser = "owo";
  networking.hostName = "dell";
  styling.name = "vibrant-wave";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.xserver.xkb = {
    layout = "us";
    variant = "altgr-intl";
  };

  security.pam.services.login.enableGnomeKeyring = true;
  security.pam.services.gdm-password.enableGnomeKeyring = true;

  networking.firewall.allowedTCPPorts = [ 8080 ];

  hardware.enableAllFirmware = true;
  services.fwupd.enable = true;

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      zlib
      zstd
      stdenv.cc.cc
      curl
      openssl
      attr
      libssh
      bzip2
      libxml2
      acl
      libsodium
      util-linux
      xz
      systemd
    ];
  };

  users.defaultUserShell = pkgs.fish;

  system.stateVersion = "25.11";
}
