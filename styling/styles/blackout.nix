{
  pkgs,
  lib,
  hostTags,
  ...
}:
let
  isNiri = builtins.elem "niri" hostTags; # todo detect at runtime via what DE is actually running
  isKdeConnect = builtins.elem "kde-connect" hostTags;

  base16 = {
    base00 = "#000000"; # Pure black background
    base01 = "#0d0d0d"; # Mantle
    base02 = "#141414"; # Crust / surface
    base03 = "#262626"; # Subtle borders / hover
    base04 = "#404040"; # Inactive borders / muted text
    base05 = "#ffffff"; # Default text (pure white)
    base06 = "#ffffff"; # Brighter text
    base07 = "#ffffff"; # Brightest white
    base08 = "#ffffff"; # Urgent
    base09 = "#d4d4d4"; # Peach
    base0A = "#c2c2c2"; # Yellow
    base0B = "#b0b0b0"; # Green
    base0C = "#9e9e9e"; # Teal
    base0D = "#ffffff"; # Blue
    base0E = "#ffffff"; # Mauve / Accent
    base0F = "#8c8c84"; # Rosewater
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
        spacing = 6;
        margin-top = 0;
        margin-left = 0;
        margin-right = 0;
        margin-bottom = 8;

        extra-modules = {
          "custom/arrow-left-bg0" = {
            format = "  ";
            tooltip = false;
          };
          "custom/arrow-right-bg0" = {
            format = "  ";
            tooltip = false;
          };
          "custom/arrow-left-bg1" = {
            format = "  ";
            tooltip = false;
          };
          "custom/arrow-right-bg1" = {
            format = "  ";
            tooltip = false;
          };
        };
      };

      moduleLeft = [
        "custom/launcher"
        "custom/arrow-left-bg1"
        "custom/arrow-right-bg0"
        "workspaces"
      ]
      ++ lib.optionals (!isNiri) [
        "sway/mode"
        "sway/scratchpad"
      ];

      modulesCenter = [
        "custom/arrow-right-bg0"
        "custom/media"
        "custom/arrow-left-bg0"
      ];

      modulesRight =
        lib.optionals isKdeConnect [
          "custom/arrow-right-bg1"
          "custom/kdeconnect"
        ]
        ++ [
          "custom/arrow-right-bg0"
          "tray"
          "custom/arrow-right-bg0"
          "group/rightinfo"
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

        #custom-launcher,
        #workspaces,
        #custom-media,
        #custom-kdeconnect,
        #tray,
        #rightinfo {
          background-color: ${c.base00};
          color: ${c.base05};
          min-height: 42px;
          padding: 0 12px;
          margin: 0;
          border-bottom: 1px solid white;
        }

        #custom-launcher,
        #custom-kdeconnect {
          background-color: ${c.base01};
        }

        #custom-arrow-left-bg0,
        #custom-arrow-right-bg0,
        #custom-arrow-left-bg1,
        #custom-arrow-right-bg1 {
          min-width: 14px;
          min-height: 42px;
          padding: 0;
          margin: 0;
          border: none;
          background-repeat: no-repeat;
          background-position: center;
          background-size: 100% 100%;
        }

        #custom-arrow-left-bg0 {
          background-image: url("file:///home/owo/.config/waybar/svg/arrow-left-bg0.svg");
          margin-left: 0;
          margin-right: 0;
        }
        #custom-arrow-right-bg0 {
          background-image: url("file:///home/owo/.config/waybar/svg/arrow-right-bg0.svg");
          margin-left: 0;
          margin-right: 0;
        }
        #custom-arrow-left-bg1 {
          background-image: url("file:///home/owo/.config/waybar/svg/arrow-left-bg1.svg");
          margin-left: 0;
          margin-right: 0;
        }
        #custom-arrow-right-bg1 {
          background-image: url("file:///home/owo/.config/waybar/svg/arrow-right-bg1.svg");
          margin-left: 0;
          margin-right: 0;
        }

        #custom-launcher {
          font-size: 15px;
          font-weight: bold;
          margin-left: 0;
        }

        #workspaces {
          padding: 0;
        }

        #workspaces button {
          min-height: 42px;
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

        #mode {
          color: ${c.base05};
          background-color: ${c.base02};
          padding: 0 13px;
        }

        #scratchpad {
          color: ${c.base05};
          padding: 0 12px;
        }

        #custom-media {
          font-weight: 600;
        }

        #rightinfo {
          padding: 0;
        }

        #rightinfo > * {
          color: ${c.base05};
          padding: 0 8px;
          margin: 0 6px;
        }

        #custom-weather { margin-left: 8px; }
        #clock { color: ${c.base05}; font-weight: bold; margin-right: 8px; }

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
          padding: 0 12px;
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
