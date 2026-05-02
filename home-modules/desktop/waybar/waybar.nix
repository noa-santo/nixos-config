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
  };

  home.file = {
    ".config/waybar/config.jsonc".source = (pkgs.writeText "config.jsonc" ''
      {
        "layer": "top",
        "modules-left": ["custom/launcher", "sway/workspaces"],
        "modules-center": ["custom/media"],
        "modules-right": ["pulseaudio", "network", "battery", "clock", "custom/time"],

        "custom/launcher": {
          "format": "",
          "on-click": "${appLauncherScript}/bin/app_launcher",
          "tooltip-format": "Launch your favorite apps"
        },

        "battery": {
          "format": "{icon}",
          "format-charging": "󰂄",
          "format-icons": ["", "", "", "", ""],
          "tooltip-format": "Battery is at {capacity}%"
        },

        "custom/time": {
          "format": "{}",
          "interval": 5,
          "exec": "date +%H:%M",
          "tooltip": false
        },

        "clock": {
          "format": "{:%a %d %b}",
          "tooltip": false
        },

        "sway/workspaces": {
          "format": "{name}"
        },

        "sway/window": {
          "format": "{class}",
          "separate-outputs": true
        },

        "network": {
          "interface": "wlo1",
          "format": "{ifname}",
          "format-wifi": "{icon}",
          "format-ethernet": "{ipaddr}/{cidr} 󰊗",
          "format-disconnected": "",
          "tooltip-format": "{ifname} via {gwaddr} 󰊗",
          "tooltip-format-wifi": "Connected to {essid} ({signalStrength}%)",
          "tooltip-format-ethernet": "{ifname} ",
          "tooltip-format-disconnected": "Disconnected",
          "max-length": 50,
          "format-icons": ["󰤯", "󰤟", "󰤢", "󰤥", "󰤨"]
        },

        "pulseaudio": {
          "format": "{icon}",
          "format-bluetooth": "󰂱",
          "format-muted": "󰖁",
          "scroll-step": 1,
          "on-click": "pavucontrol",
          "ignored-sinks": ["Easy Effects Sink"],
          "format-icons": {
            "headphone": "",
            "hands-free": "",
            "headset": "󰋎",
            "phone": "",
            "portable": "",
            "car": "",
            "default": ["󰖀", "󰕾"]
          },
          "tooltip-format": "Volume: {volume}%"
        },

        "custom/media": {
          "format": "{}",
          "escape": true,
          "return-type": "json",
          "max-length": 40,
          "on-click": "playerctl play-pause",
          "on-click-right": "playerctl stop",
          "smooth-scrolling-threshold": 1,
          "on-scroll-up": "playerctl next",
          "on-scroll-down": "playerctl previous",
          "exec": "${pkgs.python3}/bin/python3 ${mediaPlayerScript}/mediaplayer.py 2> /dev/null"
        }
      }
    '');

    ".config/waybar/style.css".source = ./style.css;
    ".config/waybar/colors.css".source = ./colors.css;

    ".config/waybar/scripts/app_launcher.sh".source = "${appLauncherScript}/bin/app_launcher.sh";
    ".config/waybar/scripts/get_weather.sh".source = "${getWeatherScript}/bin/get_weather";
    ".config/waybar/scripts/get_window.sh".source = "${getWindowScript}/bin/get_window";
    ".config/waybar/scripts/launch.sh".source = "${launchScript}/bin/launch";
    ".config/waybar/scripts/mediaplayer.py".source = mediaPlayerScript;
  };
}
