{ pkgs, osConfig, inputs, ... }:
{
  imports = [
    ../../home-modules/all.nix
  ];

  home.username = osConfig.mainUser;
  home.homeDirectory = "/home/${osConfig.mainUser}";

  home.stateVersion = "25.11";
}
