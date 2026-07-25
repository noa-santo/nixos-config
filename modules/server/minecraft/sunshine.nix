# tags: sunshine
# todo: add "server" and "minecraft" tag
{ pkgs, ... }:

let
  launchMinecraft = pkgs.writeShellScript "launch-minecraft-sunshine" ''
    ${pkgs.gamescope}/bin/gamescope -W $SUNSHINE_CLIENT_WIDTH -H $SUNSHINE_CLIENT_HEIGHT -f -- \
      ${pkgs.portablemc}/bin/portablemc start release
  '';
in
{
  environment.systemPackages = [ pkgs.portablemc ];

  services.sunshine.applications = {
    apps = [
      {
        name = "Minecraft";
        cmd = "${launchMinecraft}";
        auto-detach = "true";
        output = "/home/owo/sunshine.log";
      }
    ];
  };
}
