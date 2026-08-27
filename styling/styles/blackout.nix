{
  pkgs,
  lib,
  hostTags,
  ...
}:
let
  isNiri = builtins.elem "niri" hostTags; # todo detect at runtime via what DE is actually running
  isKdeConnect = builtins.elem "kde-connect" hostTags;
  hasLeftShortModules = (!isNiri) || isKdeConnect;

  base16 = {
    base00 = "#000000";
    base01 = "#0d0d0d";
    base02 = "#141414";
    base03 = "#262626";
    base04 = "#404040";
    base05 = "#ffffff";
    base06 = "#ffffff";
    base07 = "#ffffff";
    base08 = "#ffffff";
    base09 = "#d4d4d4";
    base0A = "#c2c2c2";
    base0B = "#b0b0b0";
    base0C = "#9e9e9e";
    base0D = "#ffffff";
    base0E = "#ffffff";
    base0F = "#8c8c84";
  };

  extra = {
    crust = "#000000";
    ov0 = "#1c1c1c";
    ov2 = "#333333";
    subtext = "#808080";
    lavender = "#ffffff";
    sapphire = "#ffffff";
    sky = "#ffffff";
    pink = "#ffffff";
  };

  c = base16 // extra;
  fontFamily = "JetBrainsMono Nerd Font";
in
{
  polarity = "dark";
  colors = c;

  image = ../../assets/wallpapers/blackout.png;
  svg = ../../assets/wallpapers/blackout.svg;

  cursor = {
    name = "phinger-cursors-dark";
    size = 24;
    package = pkgs.phinger-cursors;
  };

  icon = {
    name = "Tela-black-dark";
    dark = "Tela-black-dark";
    light = "Tela-black-dark";
    package = pkgs.tela-icon-theme;
  };

  fonts = {
    monospace = {
      name = fontFamily;
      package = pkgs.nerd-fonts.jetbrains-mono;
    };
    sansSerif = {
      name = fontFamily;
      package = pkgs.nerd-fonts.jetbrains-mono;
    };
    sizes = {
      terminal = 11;
      applications = 12;
      desktop = 12;
      popups = 12;
    };
  };

  opacity = {
    terminal = 0.97;
    applications = 1.0;
    desktop = 1.0;
    popups = 1.0;
  };

  ui = {
    icon = "Font Awesome 6 Free";

    effects = {
      blur = false;
      shadow = false;
    };

    mako.width = 380;
    wofi = {
      windowWidth = 640;
      windowHeight = 480;
    };
    sway.outerGap = 6;

    niri.shaders = {
      window-open = ../../assets/shaders/glitch/open.glsl;
      window-close = ../../assets/shaders/glitch/close.glsl;
      # todo: write a glitch resize shader
      window-resize = ../../assets/shaders/perlin/resize.glsl;
    };

    gnome = {
      screensaverPrimary = c.base00;
      screensaverSecondary = c.crust;
      arcMenu = {
        background = c.base01;
        border = "rgb(40,40,40)";
        accent = "rgb(232,232,226)";
        foreground = c.base06;
        activeBackground = "#141414";
        activeForeground = c.base07;
        separator = "rgba(255,255,255,0.08)";
        radius = 0;
      };
    };

    browser.spaces = {
      opacity = 1.0;
      texture = 0.0;
      lightness = 8;
      general = {
        red = 10;
        green = 10;
        blue = 10;
      };
      tum = {
        red = 15;
        green = 15;
        blue = 15;
      };
      bivi = {
        red = 5;
        green = 5;
        blue = 5;
      };
    };

    waybar = {
      settings = {
        height = 30;
        spacing = 0;
        margin-top = 0;
        margin-left = 0;
        margin-right = 0;
        margin-bottom = 8;

        extra-modules = {
          "custom/slant-left" = {
            format = "  ";
            tooltip = false;
          };
          "custom/slant-right" = {
            format = "  ";
            tooltip = false;
          };
          "custom/slant-left-short" = {
            format = "  ";
            tooltip = false;
          };
          "custom/slant-right-short" = {
            format = "  ";
            tooltip = false;
          };
          "custom/slant-left-div" = {
            format = "  ";
            tooltip = false;
          };
          "custom/slant-right-div" = {
            format = "  ";
            tooltip = false;
          };
        };
      };

      modulesLeft = [
        "workspaces"
      ]
      ++ lib.optionals hasLeftShortModules [
        "custom/slant-left-div"
      ]
      ++ lib.optionals (!isNiri) [
        "sway/mode"
        "sway/scratchpad"
      ]
      ++ lib.optionals isKdeConnect [
        "custom/kdeconnect"
      ]
      ++ [
        (if hasLeftShortModules then "custom/slant-left-short" else "custom/slant-left")
      ];

      modulesCenter = [
        "custom/slant-right-short"
        "custom/weather"
        "custom/slant-right-div"
        "custom/media"
        "custom/slant-left-div"
        "clock"
        "custom/slant-left-short"
      ];

      modulesRight = [
        "custom/slant-right-short"
        "tray"
        "custom/slant-right-div"
        "group/rightinfo"
      ];

      rightInfoModules = [
        "pulseaudio"
        "network"
        "cpu"
        "memory"
        "temperature"
        "disk"
        "battery"
      ];

      styleCss = ''
        * {
          font-family: "${fontFamily}", monospace;
          font-size: 13px;
          border: none;
          border-radius: 0;
          min-height: 0;
        }

        window#waybar {
          background-color: transparent;
          color: ${c.base05};
        }

        window#waybar.hidden {
          opacity: 0;
        }

        .modules-left,
        .modules-center,
        .modules-right {
          background: transparent;
          margin: 0;
        }

        #workspaces,
        #custom-media,
        #rightinfo {
          background-color: ${c.base00};
          color: ${c.base05};
          min-height: 40px;
          padding: 0 12px;
          margin: 0;
          border-bottom: 2px solid white;
        }

        #clock,
        #custom-kdeconnect,
        #mode,
        #scratchpad,
        #custom-weather,
        #tray {
          background-color: ${c.base00};
          color: ${c.base05};
          min-height: 29px;
          margin-bottom: 11px;
          padding: 0 6px;
          border-bottom: 2px solid white;
        }

        #workspaces {
          padding: 0;
        }

        #custom-slant-left,
        #custom-slant-right,
        #custom-slant-left-div,
        #custom-slant-right-div {
          min-width: 14px;
          min-height: 40px;
          padding: 0;
          margin: 0;
          border: none;
          background-repeat: no-repeat;
          background-position: center;
          background-size: 100% 100%;
        }

        #custom-slant-left-short,
        #custom-slant-right-short {
          min-width: 7px;
          min-height: 29px;
          margin-bottom: 11px;
          padding: 0;
          border: none;
          background-repeat: no-repeat;
          background-position: center;
          background-size: 100% 100%;
        }

        #custom-slant-left-short { background-image: url("file:///home/owo/.config/waybar/svg/slant-left.svg"); }
        #custom-slant-right-short { background-image: url("file:///home/owo/.config/waybar/svg/slant-right.svg"); }
        #custom-slant-left { background-image: url("file:///home/owo/.config/waybar/svg/slant-left.svg"); }
        #custom-slant-right { background-image: url("file:///home/owo/.config/waybar/svg/slant-right.svg"); }
        #custom-slant-left-div { background-image: url("file:///home/owo/.config/waybar/svg/slant-left-div.svg"); }
        #custom-slant-right-div { background-image: url("file:///home/owo/.config/waybar/svg/slant-right-div.svg"); }

        #workspaces button {
          min-height: 40px;
          padding: 0 10px;
          color: ${c.subtext};
          background: transparent;
          font-size: 15px;
          transition: all 200ms ease;
        }

        #workspaces button:hover {
          background-color: ${c.base02};
          color: ${c.base05};
        }

        #workspaces button.focused,
        #workspaces button.active {
          color: ${c.base05};
          font-weight: bold;
          border-bottom: 2px solid ${c.base05};
        }

        #workspaces button.urgent {
          color: ${c.base05};
          animation: mono-blink 1s linear infinite;
        }

        @keyframes mono-blink {
          50% { background-color: ${c.base05}; color: ${c.base00}; }
        }

        #window {
          color: ${c.base05};
          font-style: italic;
          padding: 0 13px;
        }

        #custom-media {
          font-weight: 600;
        }

        #rightinfo > * {
          color: ${c.base05};
          padding: 0 6px;
          margin: 0;
        }

        #battery { margin-right: 6px; }

        #cpu.warning,
        #memory.warning,
        #temperature.critical,
        #cpu.critical,
        #memory.critical,
        #network.disconnected,
        #battery.critical,
        #pulseaudio.muted {
          color: ${c.base05};
          font-weight: bold;
        }

        #tray {
          padding: 0 6px;
        }
        #tray > .passive { -gtk-icon-effect: dim; }
        #tray > .needs-attention {
          -gtk-icon-effect: highlight;
          background-color: ${c.base02};
        }

        #custom-kdeconnect {
          font-weight: 600;
        }

        tooltip {
          background-color: ${c.base00};
          border: 1px solid ${c.base05};
          color: ${c.base05};
          font-size: 12px;
          padding: 11px;
        }
      '';
    };
  };
}
