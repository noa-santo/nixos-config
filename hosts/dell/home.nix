{ pkgs, osConfig, inputs, lib, ... }:
{
  imports = [
    ../../home-modules/all.nix
    inputs.vicinae.homeManagerModules.default
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
