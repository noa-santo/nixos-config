# tags: wireguard
{ pkgs, config, ... }:

{
  environment.systemPackages = [ pkgs.wireguard-tools ];

  sops.secrets."wg0.conf" = {
    sopsFile = ../../secrets/wg0.conf;
    format = "binary";
  };

  networking.wg-quick.interfaces = {
    wg0 = {
      configFile = config.sops.secrets."wg0.conf".path;
      autostart = false;
    };
  };
}
