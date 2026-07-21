# no-auto-import
{
  pkgs,
  lib,
  inputs,
  ...
}:

let
  modpack = pkgs.fetchPackwizModpack {
    url = "https://raw.githubusercontent.com/noa-santo/create-modpack/server-pack/pack.toml";
    packHash = "sha256-r9ep+UbAXxtbh0lGOPWOr7u9wYHUVzZTU+AGbTaG7dw=";
  };
in
{
  services.minecraft-servers.servers.create = {
    enable = false;
    autoStart = true;

    package = pkgs.neoforgeServers.neoforge-1_21_1;

    jvmOpts = "-Xmx16G -Xms16G";

    symlinks = {
      "mods" = "${modpack}/mods";
    };

    serverProperties = {
      motd = "meow meow mrrp nya create :D";
      difficulty = "easy";
    };
  };
}
