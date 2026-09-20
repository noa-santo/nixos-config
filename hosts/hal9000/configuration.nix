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

  networking.firewall = {
    allowedTCPPorts = [ 5000 8482 8095 8097 ];
    allowedUDPPorts = [ 5353 1900 ];
    allowedUDPPortRanges = [
      { from = 6000; to = 6009; }
    ];
  }; 


  networking.hostName = "hal9000";

  system.stateVersion = "25.05";
}
