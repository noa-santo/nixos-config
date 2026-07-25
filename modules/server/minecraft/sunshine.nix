# tags: sunshine
# todo: add "server" and "minecraft" tag
{ pkgs, ... }:

let
  mods = pkgs.linkFarm "minecraft-sunshine-mods" [
  ];

  mcVersion = "fabric:26.2";
  workDir = "$HOME/.minecraft-sunshine";

  launchMinecraft = pkgs.writeShellScript "launch-sunshine-mc" ''
    mkdir -p "${workDir}/mods"
    rm -f "${workDir}/mods"/*.jar
    if compgen -G "${mods}/*.jar" > /dev/null; then
      ln -sf ${mods}/*.jar "${workDir}/mods/"
    fi

    ${pkgs.gamescope}/bin/gamescope -W $SUNSHINE_CLIENT_WIDTH -H $SUNSHINE_CLIENT_HEIGHT -f -- \
      ${pkgs.portablemc}/bin/portablemc --main-dir "${workDir}" start "${mcVersion}"
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
        output = "${workDir}/sunshine.log";
      }
    ];
  };
}
