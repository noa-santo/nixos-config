# tags: sway
{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:

let
  c = osConfig.styling.theme.palette;
  u = osConfig.styling.theme.ui;

  cheatsheetCss = builtins.toFile "cheatsheet.css" ''
    * {
        font-family: "${u.font}", monospace;
        font-size: ${toString u.fontSize.md}px;
        background-color: ${c.base};
        color: ${c.text};
    }

    window {
        border-radius: ${toString u.radius.xl}px;
        background-color: ${c.base};
    }

    row:selected {
        background-color: ${c.s0};
        color: ${c.mauve};
    }

    row:nth-child(even) {
        background-color: ${c.mantle};
    }

    header {
        background-color: ${c.crust};
        color: ${c.lavender};
        font-weight: bold;
        padding: 8px 16px;
        border-bottom: 1px solid ${c.s0};
    }
  '';

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
        --css=${cheatsheetCss}

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
    wofi # TODO: replace with vicinae
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
    librsvg
  ];

  fonts.fontconfig.enable = true;

  services.mako = {
    enable = true;
    settings = {
      font = "${u.font} ${toString u.fontSize.sm}";
      backgroundColor = c.base;
      textColor = c.text;
      borderColor = c.mauve;
      borderRadius = u.radius.md;
      borderSize = u.borderWidth;
      defaultTimeout = 5000;
      padding = "${toString u.spacing.md},${toString u.spacing.lg}";
      margin = toString u.spacing.sm;
      width = u.mako.width;
    };
    extraConfig = ''
      [urgency=high]
      border-color=${c.red}
    '';
  };

  xdg.configFile."wofi/config".text = ''
    width=${toString u.wofi.windowWidth}
    height=${toString u.wofi.windowHeight}
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
    * { font-family: "${u.font}", monospace; font-size: ${toString u.fontSize.md}px; }

    window {
      background: alpha(${c.base}, ${toString u.opacity.solid});
      border-radius: ${toString u.radius.xl}px;
      border: 1px solid ${c.s0};
    }

    #input {
      background: ${c.mantle};
      color: ${c.text};
      border: none;
      border-bottom: 1px solid ${c.s0};
      border-radius: ${toString u.radius.lg}px ${toString u.radius.lg}px 0 0;
      padding: ${toString u.spacing.md}px ${toString u.spacing.xl}px;
      font-size: ${toString u.fontSize.xl}px;
    }
    #input:focus { border-color: ${c.mauve}; }

    #inner-box, #outer-box, #scroll { background: ${u.transparent}; padding: ${toString u.spacing.xs}px; }

    #entry {
      padding: ${toString u.spacing.sm}px ${toString u.spacing.md}px;
      border-radius: ${toString u.radius.md}px;
      transition: all ${u.transitionFast};
    }
    #entry:selected { background: ${c.s0}; }

    #text { color: ${c.text}; padding: 2px 6px; }
    #entry:selected #text { color: ${c.mauve}; }

    image { margin-right: ${toString u.spacing.md}px; }
  '';

  services.swayosd = {
    enable = true;
    topMargin = 0.9;
  };

  wayland.windowManager.sway = {
    enable = true;
    package = pkgs.swayfx;
    checkConfig = false;
    wrapperFeatures.gtk = true;

    config = {
      terminal = "kitty";
      modifier = "Mod4";

      bars = [ { command = "${config.home.homeDirectory}/.config/waybar/scripts/launch.sh"; } ];

      fonts = {
        names = [
          u.font
          u.icon
        ];
        size = u.fontSize.xs + 0.0;
      };

      gaps = {
        inner = u.gap;
        outer = u.sway.outerGap;
        smartBorders = "on";
        smartGaps = true;
      };

      window = {
        border = u.borderWidth;
        titlebar = false;
        commands = [
          {
            criteria = {
              title = "Sway Keybindings";
            };
            command = "floating enable, border none, opacity ${toString u.opacity.solid}, move position center";
          }
          {
            criteria = {
              app_id = "wofi";
            };
            command = "floating enable, border none, resize set width ${toString u.wofi.windowWidth} height ${toString u.wofi.windowHeight}, move position center";
          }
          {
            criteria = {
              app_id = "pavucontrol";
            };
            command = "floating enable, resize set width 700 height 500, move position center";
          }
          {
            criteria = {
              window_type = "dialog";
            };
            command = "floating enable, move position center";
          }
        ];
      };

      floating = {
        border = u.borderWidth;
        titlebar = false;
      };

      colors = {
        focused = {
          border = c.mauve;
          background = c.base;
          inherit (c) text;
          indicator = c.mauve;
          childBorder = c.mauve;
        };
        unfocused = {
          border = c.s0;
          background = c.base;
          text = c.ov0;
          indicator = c.s1;
          childBorder = c.s0;
        };
        focusedInactive = {
          border = c.s0;
          background = c.base;
          text = c.ov0;
          indicator = c.s1;
          childBorder = c.s0;
        };
        urgent = {
          border = c.red;
          background = c.base;
          inherit (c) text;
          indicator = c.red;
          childBorder = c.red;
        };
      };

      input = {
        "type:pointer" = {
          natural_scroll = "enabled";
        };
        "type:touchpad" = {
          natural_scroll = "enabled";
          tap = "enabled";
          dwt = "enabled";
          middle_emulation = "enabled";
          scroll_method = "two_finger";
        };
        "type:keyboard" = {
          repeat_delay = "300";
          repeat_rate = "50";
        };
      };

      output."*" = {
        bg = "${osConfig.styling.theme.image} fill";
        scale = "1";
      };

      keybindings =
        let
          mod = "Mod4";
        in
        lib.mkOptionDefault {
          "${mod}+d" = "exec vicinae open";
          "${mod}+Shift+d" = "exec wofi --show run";

          # Screenshots
          "Print" = "exec sway-screenshot";
          "Shift+Print" = "exec sway-screenshot-select";

          # Brightness
          "XF86MonBrightnessUp" = "exec swayosd-client --brightness raise";
          "XF86MonBrightnessDown" = "exec swayosd-client --brightness lower";

          # Volume
          "XF86AudioRaiseVolume" = "exec swayosd-client --output-volume raise";
          "XF86AudioLowerVolume" = "exec swayosd-client --output-volume lower";
          "XF86AudioMute" = "exec swayosd-client --output-volume mute-toggle";
          "XF86AudioMicMute" = "exec swayosd-client --input-volume mute-toggle";

          # Lock
          "${mod}+Shift+l" = "exec swaylock -f -c ${c.base} --ring-color ${c.mauve}";

          "${mod}+XF86AudioMute" = "exec sway-cheatsheet";
        };
    };

    extraConfig = ''
      corner_radius ${toString u.cornerRadius}
      smart_corner_radius enable

      shadows enable
      shadow_blur_radius ${toString u.shadow.blur}
      shadow_color ${u.shadow.color}
      shadows_on_csd enable

      blur enable
      blur_passes ${toString u.shadow.passes}
      blur_radius ${toString u.shadow.spread}
      blur_xray disable

      default_dim_inactive ${toString u.opacity.subtle}
      dim_inactive_colors.unfocused ${u.dim}

      # Blur behind the waybar pill
      layer_effects waybar {
        blur enable
        blur_xray enable
        blur_ignore_transparent enable
        shadows enable
        corner_radius ${toString u.cornerRadius}
      }

      # Blur behind mako notifications
      layer_effects notifications {
        blur enable
        corner_radius ${toString u.cornerRadius}
      }

      exec_always vicinae server --replace
      exec_always ~/.config/waybar/scripts/launch.sh
    '';
  };
}
