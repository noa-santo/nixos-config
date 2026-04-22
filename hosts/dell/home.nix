{ pkgs, config, ... }:
{
  imports = [
    ../../home-modules/all.nix
  ];

  home.username = config.mainUser;
  home.homeDirectory = "/home/${config.mainUser}";

  home.stateVersion = "25.11";
}
