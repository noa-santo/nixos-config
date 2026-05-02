{ pkgs, lib, inputs, ... }:

let
  modpack = pkgs.fetchPackwizModpack {
    url = "https://raw.githubusercontent.com/noa-santo/create-modpack/refs/heads/main/pack.toml";
    packHash = "sha256-Tx6JKwrHFmoWRmdDDUzGmDsxZpFuSb88aelFDR24/q8=";
  };
in
{
  services.minecraft-servers.servers.create = {
    enable = true;
    autoStart = true;

    package = pkgs.neoforgeServers.neoforge-1_21_1;

   symlinks = {
      "mods" = "${modpack}/mods";
    };

    serverProperties = {
      motd = "meow meow mrrp nya create :D";
      difficulty = "easy";
    };
  };
}
