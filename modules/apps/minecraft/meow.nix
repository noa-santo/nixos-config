# no-auto-import
{ pkgs, lib, inputs, ... }:

{
  services.minecraft-servers.servers.meow = {
    enable = true;
    autoStart = true;

    package = pkgs.fabricServers.fabric-26_2.override {
      loaderVersion = "0.19.3";
      jre_headless = pkgs.openjdk25_headless;
    };

    symlinks = {
      mods = pkgs.linkFarmFromDrvs "mods" (
        builtins.attrValues {
          Fabric-API = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/lVXlbH4w/fabric-api-0.155.2%2B26.2.jar";
            sha256 = "sha256-1lGMdwAky+ilViSPFvzbuRxqYvUCJ6bDuugZBRHiwbg=";
          };
          Geyser = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/wKkoqHrH/versions/rRRaN6Lg/Geyser-Fabric-2.11.0-b1200.jar";
            sha256 = "sha256-sAoWWRHAJYNBkbH9lT2hMScEzl2tF2Cx30aQ3Co/wP0=";
          };
          Floodgate = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/bWrNNfkb/versions/urOFTrVX/Floodgate-Fabric-2.2.6-b67.jar";
            sha256 = "sha256-n3Nro+6GuPhhOGj+r6NfmjIYw8Re9LfkmSw06hsETcQ=";
          };
          Lithium = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/gvQqBUqZ/versions/UPNexAfy/lithium-fabric-0.25.2%2Bmc26.2.jar";
            sha256 = "sha256-dYjUp2mJSY9W4R5jorEXD/9Hbo2cSqyU4xCz59tGng8=";
          };
          LeashAll = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/oKERV1Bi/versions/KbYUstkL/leashall-fabric-26.2-26.2-1.3.4-26.2.jar";
            sha256 = "sha256-KrQHk+S3Wm2YFeQACKKtRODI2XzzsX6e3mEkIcU5B1c=";
          };
        }
      );
    };

    files = {
      "config/Geyser-Fabric/config.yml" = {
        value = {
          bedrock = {
            port = 19132;
            broadcast-port = 19132;
            clone-remote-port = false;
          };
          java = {
            auth-type = "floodgate";
          };
          motd = {
            primary-motd = "meow";
            secondary-motd = "mrrp nya meow :3";
          };
        };
      };

      "config/floodgate/config.yml" = {
        value = {
          username-prefix = "";
          replace-spaces = false;
        };
      };
    };

    serverProperties = {
      motd = "meow meow mrrp nya";
      difficulty = "peaceful";
      enforce-secure-profile = false;
    };
  };
}