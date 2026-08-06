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
    stateVersion = "26.05";
  };
}
