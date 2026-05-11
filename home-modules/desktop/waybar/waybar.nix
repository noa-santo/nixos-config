{ pkgs, config, ... }:

let
  appLauncherScript = pkgs.writeShellApplication {
    name = "app_launcher";
    runtimeInputs = [ pkgs.rofi ];
    text = builtins.readFile ./scripts/app_launcher.sh;
  };

  mediaPlayerScript = pkgs.writeText "mediaplayer.py" (builtins.readFile ./scripts/mediaplayer.py);

  getWeatherScript = pkgs.writeShellApplication {
    name = "get_weather";
    runtimeInputs = [ pkgs.curl pkgs.gnused pkgs.jq ];
    text = builtins.readFile ./scripts/get_weather.sh;
  };

  getWindowScript = pkgs.writeShellApplication {
    name = "get_window";
    runtimeInputs = [ pkgs.sway pkgs.jq ];
    text = builtins.readFile ./scripts/get_window.sh;
  };

  launchScript = pkgs.writeShellApplication {
    name = "launch";
    runtimeInputs = [ pkgs.waybar pkgs.swaynotificationcenter ];
    text = builtins.readFile ./scripts/launch.sh;
  };
in
{
  programs.waybar = {
    enable = true;
    package = pkgs.waybar;

    settings = [{
     layer    = "top";
     position = "top";
     height   = 42;
     spacing  = 6;
     margin-top    = 6;
     margin-left   = 12;
     margin-right  = 12;
     margin-bottom = 0;

     modules-left   = ["custom/launcher" "sway/workspaces" "sway/mode" "sway/scratchpad" ];
     modules-center = [ "sway/media" ];
     modules-right  = [
            "pulseaudio" "network" "cpu" "memory"
            "temperature" "disk" "battery" "clock" "custom/time" "tray"
     ];

     "custom/launcher" = {
        format = "";
        on-click = "${appLauncherScript}/bin/app_launcher";
        tooltip-format = "Launch your favorite apps";
     };

     battery = {
        format = "{icon}";
        format-charging = "󰂄";
        format-icons = ["" "" "" "" ""];
        tooltip-format = "Battery is at {capacity}%";
     };

     "custom/time" = {
        format = "{}";
        interval = 5;
        exec = "date +%H:%M";
        tooltip = false;
     };

     "sway/workspaces" = {
       disable-scroll  = true;
       all-outputs     = true;
       numeric-first   = true;
       format          = "{icon}";
       format-icons = {
          "1" = "1"; "2" = "2"; "3" = "3";
          "4" = "4"; "5" = "5"; "6" = "6";
          "7" = "7"; "8" = "8"; "9" = "9";
          "10" = "0";
          urgent   = "";
          focused  = "";
          default  = "○";
       };
     };

     "sway/window" = {
       max-length = 60;
       format     = "  {class}";
       rewrite    = {
         "(.*) - kitty"           = "  $1";
       };
     };

     "sway/mode" = {
       format = "<span style='italic'>  {}</span>";
     };

     "sway/scratchpad" = {
       format       = "{icon}  {count}";
       show-empty   = false;
       format-icons = [ "" "" ];
       tooltip      = true;
       tooltip-format = "{app}: {title}";
     };

          clock = {
            timezone       = "Europe/Berlin";
            format         = "  {:%H:%M}";
            format-alt     = "  {:%a %d %b}";
            tooltip-format = "<big>{:%B %Y}</big>\n<tt><small>{calendar}</small></tt>";
            calendar = {
              mode          = "year";
              mode-mon-col  = 3;
              on-scroll     = 1;
              on-click-right = "mode";
              format = {
                months     = "<span color='#cba6f7'><b>{}</b></span>";
                days       = "<span color='#cdd6f4'>{}</span>";
                weeks      = "<span color='#74c7ec'>W{}</span>";
                weekdays   = "<span color='#fab387'><b>{}</b></span>";
                today      = "<span color='#a6e3a1'><b><u>{}</u></b></span>";
              };
            };
          };

          cpu = {
            format   = "CPU: {usage}%";
            tooltip  = true;
            interval = 2;
            on-click = "kitty -e btop";
            states   = { warning = 70; critical = 90; };
          };

          memory = {
            format   = "🐏 {percentage}%";
            tooltip-format = "RAM: {used:0.1f}G / {total:0.1f}G\nSwap: {swapUsed:0.1f}G";
            interval = 5;
            on-click = "kitty -e btop";
            states   = { warning = 75; critical = 90; };
          };

          temperature = {
            critical-threshold = 80;
            interval = 5;
            format       = "{icon} {temperatureC}°C";
            format-critical = "⚠ {temperatureC}°C";
            format-icons = [ "🌡" "🌡" "🌡" "🌡" "🌡" ];
            tooltip      = true;
          };

          disk = {
            format   = "{free}";
            interval = 30;
            path     = "/";
            tooltip-format = "{used} / {total} used ({percentage_used}%)";
            on-click = "kitty -e btop";
          };

          network = {
            format            = "{ifname}";
            format-wifi       = "{icon}";
            format-ethernet   = "{ipaddr}  ";
            format-disconnected = "⚠  Offline";
            format-linked     = "  (no IP)";
            tooltip-format-wifi = "{essid} ({signalStrength}%)  \n{ipaddr}/{cidr}";
            tooltip-format-ethernet = "{ifname}   \n{ipaddr}/{cidr}  via {gwaddr}";
            tooltip-format-disconnected = "Disconnected";
            on-click          = "kitty -e nmtui";
            interval          = 5;
            max-length        = 50;
            format-icons      = ["󰤯" "󰤟" "󰤢" "󰤥" "󰤨"];
          };

          pulseaudio = {
            format       = "{icon} {volume}%";
            format-muted = "󰖁";
            format-bluetooth = "󰂱";
            format-icons = {
              "headphone" = "";
              "hands-free" = "";
              "headset" = "󰋎";
              "phone" = "";
              "portable" = "";
              "car" = "";
              "default" = ["󰖀" "󰕾"];
            };
            on-click       = "pavucontrol";
            on-scroll-up   = "pactl set-sink-volume @DEFAULT_SINK@ +1%";
            on-scroll-down = "pactl set-sink-volume @DEFAULT_SINK@ -1%";
            scroll-step    = 5;
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
            exec = "${pkgs.python3}/bin/python3 ${mediaPlayerScript}/mediaplayer.py 2> /dev/null";
          };

          tray = {
            spacing   = 8;
            icon-size = 18;
          };
        }];
  };

  home.file = {
    ".config/waybar/style.css".source = ./style.css;
    ".config/waybar/colors.css".source = ./colors.css;

    ".config/waybar/scripts/app_launcher.sh".source = "${appLauncherScript}/bin/app_launcher.sh";
    ".config/waybar/scripts/get_weather.sh".source = "${getWeatherScript}/bin/get_weather";
    ".config/waybar/scripts/get_window.sh".source = "${getWindowScript}/bin/get_window";
    ".config/waybar/scripts/launch.sh".source = "${launchScript}/bin/launch";
    ".config/waybar/scripts/mediaplayer.py".source = mediaPlayerScript;
  };
}
