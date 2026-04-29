{ pkgs, inputs, ... }:
let
  firefox-addons = inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system};
  containers = {
    Default = {
      color = "pink";
      icon = "circle";
      id = 1;
    };
    BiVi = {
      color = "purple";
      icon = "circle";
      id = 2;
    };
  };
in
{
  imports = [
    inputs.zen-browser.homeModules.beta
  ];

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "zen.desktop";
      "x-scheme-handler/http" = "zen.desktop";
      "x-scheme-handler/https" = "zen.desktop";
      "x-scheme-handler/about" = "zen.desktop";
      "x-scheme-handler/unknown" = "zen.desktop";
    };
  };

  programs.zen-browser = {
    enable = true;
    setAsDefaultBrowser = true;
    policies = {
      DisableAppUpdate = true;
      DisableTelemetry = true;
      DontCheckDefaultBrowser = true;
    };
    profiles.default = {
      settings = {
        "zen.workspaces.continue-where-left-off" = true;
        "zen.view.compact.hide-tabbar" = true;
        "zen.urlbar.behavior" = "float";
        "zen.welcome-screen.seen" = true;
      };

      containersForce = true;
      inherit containers;

      spacesForce = true;
      spaces = {
        "General" = {
          id = "c6de089c-410d-4206-961d-ab11f988d40a";
          position = 1000;
          icon = "⌂";
          theme = {
            type = "gradient";
            colors = [
              {
                red = 252;
                green = 5;
                blue = 136;
                algorithm = "floating";
                type = "explicit-lightness";
                lightness = 50;
              }
            ];
            opacity = 0.8;
            texture = 0.6;
          };
          container = containers.Default.id;
        };
        "BiVi" = {
          id = "284856b7-48f3-4846-abeb-14da28b1c4b6";
          position = 1000;
          icon = "⋈";
          theme = {
            type = "gradient";
            colors = [
              {
                red = 153;
                green = 2;
                blue = 229;
                algorithm = "floating";
                type = "explicit-lightness";
                lightness = 50;
              }
            ];
            opacity = 0.8;
            texture = 0.6;
          };
          container = containers.BiVi.id;
        };
      };

      extensions.packages = with firefox-addons; [
        ublock-origin
        bitwarden
      ];

      search = {
        force = true;
        default = "ddg";
        engines = {
          mynixos = {
            name = "My NixOS";
            urls = [
              {
                template = "https://mynixos.com/search?q={searchTerms}";
                params = [
                  {
                    name = "query";
                    value = "searchTerms";
                  }
                ];
              }
            ];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@nx" ];
          };
          github = {
            name = "GitHub Search";
            urls = [
              {
                template = "https://github.com/search?q={searchTerms}";
              }
            ];
            definedAliases = [ "@gh" ];
          };
        };
      };
    };
  };
}
