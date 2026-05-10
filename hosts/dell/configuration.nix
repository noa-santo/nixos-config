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

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.fprintd = {
    enable = true;
    package = pkgs.fprintd.override {
      libfprint = pkgs.libfprint-goodix53x5;
    };
  };
  services.udev.packages = [ pkgs.libfprint-goodix53x5 ];
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTR{idVendor}=="27c6", ATTR{idProduct}=="5385", ATTR{power/control}="on", ATTR{power/persist}="1", ENV{ID_AUTOSUSPEND}="0"
  '';

  security.pam.services.login.fprintAuth = lib.mkForce true;
  security.pam.services.sudo.fprintAuth = lib.mkForce true;
  security.pam.services.gdm-fingerprint.fprintAuth = lib.mkForce true;

  system.stateVersion = "25.11";
}
