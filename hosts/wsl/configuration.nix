{ inputs, ... }:
{
  imports = [
    inputs.nixos-wsl.nixosModules.default
    ../../modules/all.nix
  ];

  wsl = {
    enable = true;
    defaultUser = "owo";
    useWindowsDriver = true;
  };

  mainUser = "owo";
  networking.hostName = "wsl";

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  system.stateVersion = "26.05";
}
