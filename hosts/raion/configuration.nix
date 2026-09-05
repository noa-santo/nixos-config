{ inputs, ... }:
{
  imports = [
    inputs.nixos-wsl.nixosModules.default
    ../../modules/all.nix
  ];

  wsl = {
    enable = true;
    defaultUser = "n";
    useWindowsDriver = true;
  };

  mainUser = "n";
  networking.hostName = "raion";

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  system.stateVersion = "26.05";
}
