{ pkgs, lib, config, ... }:

let
  c = {
    base     = "#1e1e2e"; mantle   = "#181825"; crust    = "#11111b";
    s0       = "#313244"; s1       = "#45475a"; s2       = "#585b70";
    ov0      = "#6c7086"; ov2      = "#9399b2";
    text     = "#cdd6f4"; subtext  = "#a6adc8";
    mauve    = "#cba6f7"; blue     = "#89b4fa"; lavender = "#b4befe";
    sapphire = "#74c7ec"; teal     = "#94e2d5"; green    = "#a6e3a1";
    yellow   = "#f9e2af"; peach    = "#fab387"; red      = "#f38ba8";
    pink     = "#f5c2e7"; sky      = "#89dceb";
  };

  cheatsheetScript = pkgs.writeShellScriptBin "sway-cheatsheet" ''
    #!/bin/sh
    CONFIG_FILE="$HOME/.config/sway/config"
    LOCK_FILE="/tmp/sway-cheatsheet.lock"

    [ -f "$LOCK_FILE" ] && exit 0

    if [ ! -f "$CONFIG_FILE" ]; then
      yad --error --text="Sway config not found at $CONFIG_FILE"
      exit 1
    fi

    touch "$LOCK_FILE"

    awk '
    /^\s*bindsym/ {
      line = $0
      if (line ~ /pkill/ || line ~ /sway-cheatsheet/) next
      gsub(/^\s*bindsym\s+/, "", line)
      while (line ~ /^--[a-z]/) sub(/^--[a-z][a-z-]*\s+/, "", line)
      n = split(line, parts, " ")
      key = parts[1]
      action = ""
      for (i = 2; i <= n; i++) action = action " " parts[i]
      gsub(/^\s+|\s+$/, "", action)
      gsub(/^exec\s+/, "", action)
      gsub(/--[a-z][a-z-]*\s*/, "", action)
      gsub(/^\s+|\s+$/, "", action)
      if (key != "" && action != "") print key "\n" action
    }
    ' "$CONFIG_FILE" | yad \
        --title="Sway Keybindings" \
        --list \
        --width=1200 --height=720 \
        --column="Keybinding" \
        --column="Action" \
        --no-buttons --fixed \
        --css=${./cheatsheet.css}

    rm -f "$LOCK_FILE"
  '';

  screenshotScript = pkgs.writeShellScriptBin "sway-screenshot" ''
    #!/bin/sh
    grim - | wl-copy --type image/png
    notify-send "Screenshot copied to clipboard" -t 2000
  '';

  screenshotSelectScript = pkgs.writeShellScriptBin "sway-screenshot-select" ''
    #!/bin/sh
    grim -g "$(slurp)" - | wl-copy --type image/png
    notify-send "Screenshot copied to clipboard" -t 2000
  '';

in
{
  home.packages = with pkgs; [
    brightnessctl
    grim
    slurp
    playerctl
    pulseaudio
    swayidle
    swaylock
    wmenu
    swaybg
    wofi # TODO: replace with anyrun, walker or vicinae
    wl-clipboard
    mako
    waybar
    pavucontrol
    yad
    btop
    networkmanagerapplet
    nerd-fonts.jetbrains-mono
    font-awesome
    cheatsheetScript
    screenshotScript
    screenshotSelectScript
  ];

  fonts.fontconfig.enable = true;

  services.mako = {
    enable       = true;
    settings = {
      font         = "JetBrains Mono 11";
      backgroundColor = c.base;
      textColor    = c.text;
      borderColor  = c.mauve;
      borderRadius = 10;
      borderSize   = 2;
      defaultTimeout = 5000;
      padding      = "12,16";
      margin       = "8";
      width        = 380;
    };
    extraConfig  = ''
      [urgency=high]
      border-color=${c.red}
    '';
  };

  xdg.configFile."wofi/config".text = ''
    width=640
    height=480
    allow_images=true
    allow_markup=true
    insensitive=true
    prompt=Search apps...
    hide_scroll=true
    normal_window=true
    no_actions=true
    term=kitty
    filter_rate=100
    lines=12
  '';

  xdg.configFile."wofi/style.css".text = ''
    * { font-family: "JetBrainsMono Nerd Font", monospace; font-size: 14px; }

    window {
      background: alpha(#1e1e2e, 0.92);
      border-radius: 16px;
      border: 1px solid #313244;
    }

    #input {
      background: #181825;
      color: #cdd6f4;
      border: none;
      border-bottom: 1px solid #313244;
      border-radius: 14px 14px 0 0;
      padding: 12px 18px;
      font-size: 16px;
    }
    #input:focus { border-color: #cba6f7; }

    #inner-box, #outer-box, #scroll { background: transparent; padding: 4px; }

    #entry {
      padding: 8px 12px;
      border-radius: 10px;
      transition: all 150ms ease;
    }
    #entry:selected { background: #313244; }

    #text { color: #cdd6f4; padding: 2px 6px; }
    #entry:selected #text { color: #cba6f7; }

    image { margin-right: 10px; }
  '';

  wayland.windowManager.sway = {
    enable     = true;
    package    = pkgs.swayfx;
    checkConfig = false;
    wrapperFeatures.gtk = true;

    config = {
      terminal = "kitty";
      modifier = "Mod4";

      bars = [{ command = "${config.home.homeDirectory}/.config/waybar/scripts/launch.sh"; }];

      fonts = {
        names = [ "JetBrainsMono Nerd Font" "Font Awesome 6 Free" ];
        size  = 11.0;
      };

      gaps = {
        inner        = 8;
        outer        = 6;
        smartBorders = "on";
        smartGaps    = true;
      };

      window = {
        border   = 2;
        titlebar = false;
        commands = [
          {
            criteria = { title = "Sway Keybindings"; };
            command  = "floating enable, border none, opacity 0.92, move position center";
          }
          {
            criteria = { app_id = "wofi"; };
            command  = "floating enable, border none, resize set width 640 height 480, move position center";
          }
          {
            criteria = { app_id = "pavucontrol"; };
            command  = "floating enable, resize set width 700 height 500, move position center";
          }
          {
            criteria = { window_type = "dialog"; };
            command  = "floating enable, move position center";
          }
        ];
      };

      floating = { border = 2; titlebar = false; };

      colors = {
        focused = {
          border = c.mauve; background = c.base; text = c.text;
          indicator = c.mauve; childBorder = c.mauve;
        };
        unfocused = {
          border = c.s0; background = c.base; text = c.ov0;
          indicator = c.s1; childBorder = c.s0;
        };
        focusedInactive = {
          border = c.s0; background = c.base; text = c.ov0;
          indicator = c.s1; childBorder = c.s0;
        };
        urgent = {
          border = c.red; background = c.base; text = c.text;
          indicator = c.red; childBorder = c.red;
        };
      };

      input = {
        "type:pointer" = {
          natural_scroll = "enabled";
        };
        "type:touchpad" = {
          natural_scroll   = "enabled";
          tap              = "enabled";
          dwt              = "enabled";
          middle_emulation = "enabled";
          scroll_method    = "two_finger";
        };
        "type:keyboard" = {
          repeat_delay = "300";
          repeat_rate  = "50";
        };
      };

      output."*" = {
        bg    = "/run/current-system/sw/share/backgrounds/gnome/blobs-l.svg fill";
        scale = "1";
      };

      keybindings = let mod = "Mod4"; in lib.mkOptionDefault {
        "${mod}+d"       = ''exec wofi --show drun'';
        "${mod}+Shift+d" = ''exec wofi --show run'';

        # Screenshots
        "Print"       = "exec sway-screenshot";
        "Shift+Print" = "exec sway-screenshot-select";

        # Brightness
        "XF86MonBrightnessUp"   = "exec brightnessctl set +5%";
        "XF86MonBrightnessDown" = "exec brightnessctl set 5%-";

        # Volume
        "XF86AudioRaiseVolume"  = "exec pactl set-sink-volume @DEFAULT_SINK@ +5%";
        "XF86AudioLowerVolume"  = "exec pactl set-sink-volume @DEFAULT_SINK@ -5%";
        "XF86AudioMute"         = "exec pactl set-sink-mute @DEFAULT_SINK@ toggle";
        "XF86AudioMicMute"      = "exec pactl set-source-mute @DEFAULT_SOURCE@ toggle";

        # Lock
        "${mod}+Shift+l" = "exec swaylock -f -c 1e1e2e";

        "${mod}+XF86AudioMute" = "exec sway-cheatsheet";
      };
    };

    extraConfig = ''
      # ── SwayFX visual effects ───────────────────────────────────────────────
      corner_radius 12
      smart_corner_radius enable

      shadows enable
      shadow_blur_radius 20
      shadow_color #00000066
      shadows_on_csd enable

      blur enable
      blur_passes 3
      blur_radius 5
      blur_xray disable

      default_dim_inactive 0.15
      dim_inactive_colors.unfocused #000000FF

      # Blur behind the waybar pill
      layer_effects waybar {
        blur enable
        blur_xray enable
        blur_ignore_transparent enable
        shadows enable
        corner_radius 12
      }

      # Blur behind mako notifications
      layer_effects notifications {
        blur enable
        corner_radius 12
      }

      # ── Idle / lock ─────────────────────────────────────────────────────────
      exec swayidle -w \
        timeout 300  'swaylock -f -c 1e1e2e' \
        timeout 600  'swaymsg "output * dpms off"' \
        resume       'swaymsg "output * dpms on"' \
        before-sleep 'swaylock -f -c 1e1e2e'
    '';
  };
}
