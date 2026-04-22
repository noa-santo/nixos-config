{ pkgs, lib, ... }:
{
  imports = [
    ../../modules/all.nix
  ];

  mainUser = "u200b";

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  networking.hostName = "nixos";

  system.stateVersion = "25.05";
}
