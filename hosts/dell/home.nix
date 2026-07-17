{ pkgs, osConfig, inputs, lib, ... }:
{
  imports = [
    ../../home-modules/all.nix
  ];

  home.username = osConfig.mainUser;
  home.homeDirectory = "/home/${osConfig.mainUser}";

  wayland.windowManager.sway = {
    config = {
      output."*".scale = lib.mkForce "2";
    };
  };

  home.stateVersion = "25.11";
}
