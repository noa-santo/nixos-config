{ pkgs, ... }:
{
  imports = [
    ../../home-modules/all.nix
  ];

  home.username = "owo";
  home.homeDirectory = "/home/owo";

  home.stateVersion = "25.11";
}
