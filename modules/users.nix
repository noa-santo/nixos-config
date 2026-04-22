{ pkgs, lib, config, ... }:

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
      extraGroups = [ "networkmanager" "wheel" "video" "input" ];
      shell = pkgs.fish;
    };
  };
}
