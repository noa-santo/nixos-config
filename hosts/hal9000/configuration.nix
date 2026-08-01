{ ... }:
{
  imports = [
    ../../modules/all.nix
  ];

  mainUser = "u200b";

  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
    useOSProber = true;
  };

  networking.hostName = "hal9000";

  system.stateVersion = "25.05";
}
