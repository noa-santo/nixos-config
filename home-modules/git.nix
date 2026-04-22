{ config, pkgs, ... }:
{
  programs.git = {
    enable = true;
    settings.user = {
        email = "uwu@owo.computer";
        name = config.home.username;
    };
  };
}
