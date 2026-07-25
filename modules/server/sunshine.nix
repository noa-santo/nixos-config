# tags: sunshine
# todo: add "server" tag
{ pkgs, config, ... }:
{
  environment.systemPackages = [ pkgs.gamescope ];

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
