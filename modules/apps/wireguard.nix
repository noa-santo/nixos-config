# tags: wireguard
{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.wireguard-tools ];

  networking.wg-quick.interfaces = {
    wg0 = {
      configFile = "/etc/wireguard/wg0.conf";
      autostart = false;
    };
  };
}
