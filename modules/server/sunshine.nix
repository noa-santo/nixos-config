# tags: sunshine
# todo: add "server" tag
{ config, ... }:
{
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
  };

  users.users.${config.mainUser} = {
    extraGroups = [ "uinput" ];
  };

  hardware.uinput.enable = true;
}
