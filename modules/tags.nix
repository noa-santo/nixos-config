{ config, lib, pkgs, ... }:

{
  options.tags = lib.mkOption {
    type = lib.types.listOf (lib.types.enum [
      "gnome"
      "sway"
      "plasma"
      "headless"
      "laptop"
      "desktop"
      "server"
      "gaming"
      "minecraft-server"
      "dev"
      "docker"
    ]);
    default = [];
    description = "A list of tags for this host, used for conditional configuration.";
  };
}
