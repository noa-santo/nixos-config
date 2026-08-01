{
  osConfig,
  lib,
  ...
}:
{
  imports = [
    ../../home-modules/all.nix
  ];

  home = {
    username = osConfig.mainUser;
    homeDirectory = "/home/${osConfig.mainUser}";
    stateVersion = "25.11";
  };

  wayland.windowManager.sway = {
    config = {
      output."*".scale = lib.mkForce "2";
    };
  };
}
