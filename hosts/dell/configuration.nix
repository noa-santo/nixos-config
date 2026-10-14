{ pkgs, ... }:
{
  zramSwap.enable = true;
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

  boot.kernelModules = [
    "hid-nintendo"
    "btusb"
  ];
  environment.systemPackages = with pkgs; [
    joycond
  ];
  services.joycond.enable = true;
  hardware.bluetooth.enable = true;
  hardware.bluetooth.settings = {
    General = {
      Privacy = "device";
      Experimental = true;
    };
  };

  system.stateVersion = "25.11";
}
