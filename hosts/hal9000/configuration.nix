{ ... }:
{
  imports = [
    ../../modules/all.nix
  ];

  mainUser = "u200b";
  styling.name = "vibrant-wave";

  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
    useOSProber = true;
  };

  networking.firewall.allowedTCPPorts = [ 8482 ];

  networking.hostName = "hal9000";

  system.stateVersion = "25.05";
}
