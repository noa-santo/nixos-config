{ pkgs, lib, inputs, ... }:

{
  networking.firewall.allowedUDPPorts = [ 19132 ];

  services.minecraft-servers = {
    enable = true;
    eula = true;
    openFirewall = true;

    servers.meow = {
      enable = false;
      autoStart = true;

      package = pkgs.fabricServers.fabric-1_21_11.override {
        loaderVersion = "0.18.4";
      };

      symlinks = {
        mods = pkgs.linkFarmFromDrvs "mods" (
          builtins.attrValues {
            Fabric-API = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/i5tSkVBH/fabric-api-0.141.3%2B1.21.11.jar";
              sha256 = "hsRTqGE5Zi53VpfQOwynhn9Uc3SGjAyz49wG+Y2/7vU=";
            };
            Geyser = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/wKkoqHrH/versions/BhQ8mVAx/geyser-fabric-Geyser-Fabric-2.9.4-b1081.jar";
              sha256 = "mblFlIOh5eNx4NAbtv03BKKTUQOc6iqjzqMlOePiUx8=";
            };
            Floodgate = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/bWrNNfkb/versions/wzwExuYr/Floodgate-Fabric-2.2.6-b54.jar";
              sha256 = "KVfeM69JWnYBpTyKfGMbXH9SayR+/GJ50RWxd7Y258g=";
            };
            Lithium = pkgs.fetchurl {
             url = "https://cdn.modrinth.com/data/gvQqBUqZ/versions/qvNsoO3l/lithium-fabric-0.21.3%2Bmc1.21.11.jar";
             sha512 = "2883739303f0bb602d3797cc601ed86ce6833e5ec313ddce675f3d6af3ee6a40b9b0a06dafe39d308d919669325e95c0aafd08d78c97acd976efde899c7810fd";
            };
            LeashablePlayer = pkgs.fetchurl {
             url = "https://cdn.modrinth.com/data/BKyMf6XK/versions/15ItkoRt/leashmod-1.2.5%2B1.21.11.jar";
             sha512 = "sha512-cYs+NhbAOTUnOjo49pXg5oqWy5yCG/N8Hgvg0FZXT8xf1lcwygFq+lSetrrsSBRkgU3Xpww49dfH/SGuoLtwBg==";
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
  };

  users.users.minecraft = {
    isSystemUser = true;
    home = "/srv/minecraft";
    shell = pkgs.bash;
  };
}
