{
  pkgs,
  lib,
  osConfig,
  hostTags ? [ ],
  ...
}:

let
  isNiri = builtins.elem "niri" hostTags; # todo detect at runtime via what DE is actually running
  isKdeConnect = builtins.elem "kde-connect" hostTags;
  workspacesModule = if isNiri then "niri/workspaces" else "sway/workspaces";

  c = osConfig.styling.theme.palette;
  u = osConfig.styling.theme.ui;

  styleCss = ''
    @define-color base ${c.base};
    @define-color text ${c.text};
    @define-color subtext ${c.subtext};
    @define-color s0 ${c.s0};
    @define-color s1 ${c.s1};
    @define-color mauve ${c.mauve};
    @define-color red ${c.red};
    @define-color lavender ${c.lavender};
    @define-color blue ${c.blue};
    @define-color yellow ${c.yellow};
    @define-color teal ${c.teal};
    @define-color green ${c.green};
    @define-color sky ${c.sky};
    @define-color sapphire ${c.sapphire};
    @define-color pink ${c.pink};
    @define-color peach ${c.peach};
    @define-color mantle ${c.mantle};

    * {
      font-family: "${u.font}", monospace;
      font-size: ${toString u.fontSize.md}px;
      border: none;
      border-radius: ${toString u.cornerRadius}px;
      min-height: 0;
    }

    window#waybar {
      background-color: alpha(@base, ${toString u.opacity.low});
      color: @text;
    }

    .modules-center,
    .modules-right {
      background: ${u.transparent};
      margin: ${toString u.spacing.xs}px;
    }

    .modules-right > * {
      background-color: alpha(@base, ${toString u.opacity.mid});
      border: 1px solid alpha(@text, ${toString u.opacity.hairline});
      border-radius: ${toString u.cornerRadius}px;
      padding: 0 ${toString u.spacing.sm}px;
    }

    #workspaces,
    #mode,
    #scratchpad,
    #window,
    #clock,
    #cpu,
    #memory,
    #temperature,
    #disk,
    #network,
    #pulseaudio,
    #battery,
    #tray,
    #custom-weather,
    #custom-kdeconnect {
      margin: 0 ${toString u.spacing.sm}px;
      color: @text;
    }

    #custom-weather {
      margin-left: ${toString u.spacing.md}px;
    }

    #clock {
      margin-right: ${toString u.spacing.md}px;
    }

    #workspaces button {
      padding: 2px 8px;
      color: @subtext;
      background: transparent;
      border-radius: ${toString u.radius.sm}px;
      transition: all ${u.transition};
      font-size: ${toString u.fontSize.lg}px;
    }

    #workspaces button:hover {
      background: @s0;
      color: @text;
      box-shadow: none;
    }

    #workspaces button.focused {
      color: @mauve;
      font-weight: bold;
    }

    #workspaces button.urgent {
      color: @red;
      animation: blink ${u.animation.pulse};
    }

    @keyframes blink {
      to { color: @base; background: @red; }
    }

    #custom-launcher {
        margin: 0 ${toString u.spacing.xl}px 0 ${toString u.spacing.xl}px;
    }

    #clock {
      color: @lavender;
      font-weight: bold;
    }

    #custom-media {
      background-color: alpha(@base, ${toString u.opacity.mid});
      border: 1px solid alpha(@text, ${toString u.opacity.hairline});
      border-radius: ${toString u.cornerRadius}px;
      margin: ${toString u.spacing.xs}px;
      padding: 0 ${toString u.spacing.md}px;
      font-weight: 700;
    }

    #window {
      color: @subtext;
      font-style: italic;
    }

    #cpu { color: @blue; }
    #cpu.warning  { color: @yellow; }
    #cpu.critical { color: @red; }

    #memory { color: @teal; }
    #memory.warning  { color: @yellow; }
    #memory.critical { color: @red; }

    #temperature { color: @green; }
    #temperature.critical { color: @red; }

    #disk { color: @sky; }

    #network { color: @sapphire; }
    #network.disconnected { color: @red; }

    #pulseaudio { color: @pink; }
    #pulseaudio.muted { color: @s1; }

    #mode {
      color: @peach;
      background: @s0;
      border-radius: 8px;
      padding: 2px 12px;
      font-weight: bold;
    }

    #tray > .passive { -gtk-icon-effect: dim; }
    #tray > .needs-attention {
      -gtk-icon-effect: highlight;
      background: alpha(@red, ${toString u.opacity.faint});
      border-radius: ${toString u.radius.xs}px;
    }

    tooltip {
      background-color: alpha(@mantle, ${toString u.opacity.high});
      border: 1px solid @s0;
      border-radius: ${toString u.radius.md}px;
      color: @text;
      font-size: ${toString u.fontSize.sm}px;
      padding: ${toString u.spacing.xs}px;
    }
  '';

  pythonWithGObject = pkgs.python3.withPackages (ps: [ ps.pygobject3 ]);
  playerctlTypelibPath = pkgs.lib.makeSearchPath "lib/girepository-1.0" [
    pkgs.playerctl
    pkgs.glib
  ];
  playerctlLibraryPath = pkgs.lib.makeLibraryPath [
    pkgs.playerctl
    pkgs.glib
  ];

  appLauncherScript = pkgs.writeShellApplication {
    name = "app_launcher";
    runtimeInputs = [ pkgs.rofi ];
    text = builtins.readFile ./scripts/app_launcher.sh;
  };

  mediaPlayerScript = pkgs.writeShellApplication {
    name = "mediaplayer";
    runtimeInputs = [ pkgs.playerctl ];
    text = ''
      export GI_TYPELIB_PATH="${playerctlTypelibPath}:''${GI_TYPELIB_PATH:-}"
      export LD_LIBRARY_PATH="${playerctlLibraryPath}:''${LD_LIBRARY_PATH:-}"
      exec ${pythonWithGObject}/bin/python3 ${./scripts/mediaplayer.py} "$@"
    '';
  };

  getWeatherScript = pkgs.writeShellApplication {
    name = "get_weather";
    runtimeInputs = [
      pkgs.curl
      pkgs.gnused
      pkgs.jq
    ];
    text = builtins.readFile ./scripts/get_weather.sh;
  };

  getWindowScript = pkgs.writeShellApplication {
    name = "get_window";
    runtimeInputs = [
      pkgs.sway
      pkgs.jq
    ];
    text = builtins.readFile ./scripts/get_window.sh;
  };

  launchScript = pkgs.writeShellApplication {
    name = "launch";
    runtimeInputs = [
      pkgs.waybar
      pkgs.swaynotificationcenter
    ];
    text = builtins.readFile ./scripts/launch.sh;
  };

  niriOrderWorkspacesScript = pkgs.writeShellApplication {
    name = "niri-order-workspaces";
    runtimeInputs = [ pkgs.niri-stable ];
    text = builtins.readFile ./scripts/niri_order_workspaces.sh;
  };
in
{
  programs.waybar = {
    enable = true;
    package = pkgs.waybar;

    settings = [
      {
        layer = "top";
        position = "top";
        height = 42;
        spacing = 6;
        margin-top = 6;
        margin-left = 12;
        margin-right = 12;
        margin-bottom = 8;

        modules-left = [
          "custom/launcher"
          workspacesModule
        ]
        ++ lib.optionals (!isNiri) [
          "sway/mode"
          "sway/scratchpad"
        ];
        modules-center = [ "custom/media" ];
        modules-right = lib.optionals isKdeConnect [ "custom/kdeconnect" ] ++ [
          "tray"
          "group/rightinfo"
        ];

        "group/rightinfo" = {
          orientation = "horizontal";
          modules = [
            "custom/weather"
            "pulseaudio"
            "network"
            "cpu"
            "memory"
            "temperature"
            "disk"
            "battery"
            "clock"
          ];
        };

        "custom/launcher" = {
          format = "";
          on-click = "${appLauncherScript}/bin/app_launcher";
          tooltip-format = "Launch your favorite apps";
        };

        "custom/weather" = {
          format = "{}";
          return-type = "json";
          tooltip = true;
          exec = "${getWeatherScript}/bin/get_weather Munich";
          interval = 300;
        };

        battery = {
          format = "{icon}";
          format-charging = "󰂄";
          format-icons = [
            ""
            ""
            ""
            ""
            ""
          ];
          tooltip-format = "Battery is at {capacity}%";
        };

        "sway/workspaces" = {
          disable-scroll = true;
          all-outputs = true;
          numeric-first = true;
          format = "{icon}";
          format-icons = {
            "1" = "1";
            "2" = "2";
            "3" = "3";
            "4" = "4";
            "5" = "5";
            "6" = "6";
            "7" = "7";
            "8" = "8";
            "9" = "9";
            "10" = "0";
            urgent = "!";
            focused = "";
            default = "○";
          };
        };

        "sway/window" = {
          max-length = 60;
          format = "  {class}";
          rewrite = {
            "(.*) - kitty" = "  $1";
          };
        };

        "sway/mode" = {
          format = "<span style='italic'>  {}</span>";
        };

        "niri/workspaces" = {
          disable-scroll = true;
          format = "{icon}";
          format-icons = {
            "browser" = "";
            "ide" = "";
            "social" = "󰭹";
            "terminal" = "";
            "1" = "1";
            "2" = "2";
            "3" = "3";
            "4" = "4";
            "5" = "5";
            "6" = "6";
            "7" = "7";
            "8" = "8";
            "9" = "9";
            "10" = "0";
            urgent = "!";
            active = "";
            default = "○";
          };
          on-update = "${niriOrderWorkspacesScript}/bin/niri-order-workspaces";
        };

        "niri/window" = {
          max-length = 60;
          format = "  {title}";
        };

        "sway/scratchpad" = {
          format = "{icon}  {count}";
          show-empty = false;
          format-icons = [
            ""
            ""
          ];
          tooltip = true;
          tooltip-format = "{app}: {title}";
        };

        clock = {
          timezone = "Europe/Berlin";
          format = " {:%H:%M}";
          format-alt = " {:%a %d %b}";
          tooltip-format = "<big>{:%B %Y}</big>\n<tt><small>{calendar}</small></tt>";
          calendar = {
            mode = "year";
            mode-mon-col = 3;
            on-scroll = 1;
            on-click-right = "mode";
            format = {
              months = "<span color='${c.mauve}'><b>{}</b></span>";
              days = "<span color='${c.text}'>{}</span>";
              weeks = "<span color='${c.sapphire}'>W{}</span>";
              weekdays = "<span color='${c.peach}'><b>{}</b></span>";
              today = "<span color='${c.green}'><b><u>{}</u></b></span>";
            };
          };
        };

        cpu = {
          format = " {usage}%";
          tooltip = true;
          interval = 2;
          on-click = "kitty -e btop";
          states = {
            warning = 70;
            critical = 90;
          };
        };

        memory = {
          format = "🐏 {percentage}%";
          tooltip-format = "RAM: {used:0.1f}G / {total:0.1f}G\nSwap: {swapUsed:0.1f}G";
          interval = 5;
          on-click = "kitty -e btop";
          states = {
            warning = 75;
            critical = 90;
          };
        };

        temperature = {
          critical-threshold = 80;
          interval = 5;
          format = "{icon} {temperatureC}°C";
          format-critical = "⚠ {temperatureC}°C";
          format-icons = [
            "🌡"
            "🌡"
            "🌡"
            "🌡"
            "🌡"
          ];
          tooltip = true;
        };

        disk = {
          format = "{free}";
          interval = 30;
          path = "/";
          tooltip-format = "{used} / {total} used ({percentage_used}%)";
          on-click = "kitty -e btop";
        };

        network = {
          format = "{ifname}";
          format-wifi = "{icon}";
          format-ethernet = "{ipaddr}  ";
          format-disconnected = "⚠  Offline";
          format-linked = "  (no IP)";
          tooltip-format-wifi = "{essid} ({signalStrength}%)  \n{ipaddr}/{cidr}";
          tooltip-format-ethernet = "{ifname}   \n{ipaddr}/{cidr}  via {gwaddr}";
          tooltip-format-disconnected = "Disconnected";
          on-click = "kitty -e nmtui";
          interval = 5;
          max-length = 50;
          format-icons = [
            "󰤯"
            "󰤟"
            "󰤢"
            "󰤥"
            "󰤨"
          ];
        };

        pulseaudio = {
          format = "{icon} {volume}%";
          format-muted = "󰖁";
          format-bluetooth = "󰂱";
          format-icons = {
            "headphone" = "";
            "hands-free" = "";
            "headset" = "󰋎";
            "phone" = "";
            "portable" = "";
            "car" = "";
            "default" = [
              "󰖀"
              "󰕾"
            ];
          };
          on-click = "pavucontrol";
          on-scroll-up = "pactl set-sink-volume @DEFAULT_SINK@ +1%";
          on-scroll-down = "pactl set-sink-volume @DEFAULT_SINK@ -1%";
          scroll-step = 5;
        };

        "custom/media" = {
          format = "{}";
          escape = true;
          return-type = "json";
          max-length = 40;
          on-click = "playerctl play-pause";
          on-click-right = "playerctl stop";
          smooth-scrolling-threshold = 1;
          on-scroll-up = "playerctl next";
          on-scroll-down = "playerctl previous";
          exec = "${mediaPlayerScript}/bin/mediaplayer";
        };

        "custom/kdeconnect" = {
          format = "{}";
          exec = "kdeconnect_waybar";
          return-type = "json";
          on-click = "kdeconnect-app";
        };

        tray = {
          spacing = 8;
          icon-size = 18;
        };
      }
    ];
  };

  home.file = {
    ".config/waybar/style.css".text = styleCss;

    ".config/waybar/scripts/app_launcher.sh".source = "${appLauncherScript}/bin/app_launcher.sh";
    ".config/waybar/scripts/get_weather.sh".source = "${getWeatherScript}/bin/get_weather";
    ".config/waybar/scripts/get_window.sh".source = "${getWindowScript}/bin/get_window";
    ".config/waybar/scripts/launch.sh".source = "${launchScript}/bin/launch";
    ".config/waybar/scripts/mediaplayer.py".source = "${mediaPlayerScript}/bin/mediaplayer";
  };
}
