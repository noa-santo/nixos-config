{
  pkgs,
  lib,
  config,
  hostTags ? [],
  ...
}:
let 
  isDocker = builtins.elem "docker" hostTags;
in
{
  options = {
    mainUser = lib.mkOption {
      type = lib.types.str;
      description = "The main user of the system";
    };
  };

  config = {
    users.users.${config.mainUser} = {
      isNormalUser = true;
      description = lib.mkDefault config.mainUser;
      extraGroups = [
        "networkmanager"
        "wheel"
        "video"
        "input"
      ] ++ lib.optionals isDocker [ "docker" ];
      shell = pkgs.fish;
    };
  };
}
