{pkgs, ...}:
let
  cheatsheetScript = pkgs.writeShellScriptBin "sway-cheatsheet" ''
    #!/bin/sh
    CONFIG_FILE="$HOME/.config/sway/config"
    LOCK_FILE="/tmp/sway-cheatsheet.lock"

    if [ -f "$LOCK_FILE" ]; then
      exit 0
    fi

    if [ ! -f "$CONFIG_FILE" ]; then
      yad --error --text="Sway config not found at $CONFIG_FILE"
      exit 1
    fi

    touch "$LOCK_FILE"

    # Use awk to parse the sway config and format it for yad --list
    awk '
    /\s*bindsym/ {
      if ($0 ~ /--release/ && $0 ~ /pkill yad/) { next }
      key = $2
      action = $0
      sub(/bindsym/, "", action)
      sub(key, "", action)
      gsub(/--[a-z-]+/, "", action)
      gsub(/exec/, "", action)
      gsub(/^[ \t]+|[ \t]+$/, "", action)
      print key
      print action
    }
    ' "$CONFIG_FILE" | yad --class="sway-cheatsheet" --list --width=1536 --height=864 --title="Sway Keybindings" --column="Keybinding" --column="Action" --no-buttons --fixed --undecorated --css=${./cheatsheet.css}

    rm "$LOCK_FILE"
  '';
in
{
  home.packages = with pkgs; [
    brightnessctl
    grim
    pulseaudio
    swayidle
    swaylock
    wmenu
    swaybg
    wofi
    wl-clipboard
    mako
    waybar
    pavucontrol
    yad
    cheatsheetScript
  ];

  wayland.windowManager.sway = {
    enable = true;
    package = pkgs.swayfx;
    checkConfig = false;
    wrapperFeatures.gtk = true;
    config = {
      terminal = "kitty";
      modifier = "Mod4";
      bars = [{
        command = "waybar";
      }];
      output."*".bg = "/run/current-system/sw/share/backgrounds/gnome/blobs-l.svg fill";
      output."*".scale = "1";
    };
    extraConfig = ''
      # swayfx settings
      corner_radius 10
      shadows enable
      shadow_blur_radius 20
      shadow_color #000000BF
      blur enable
      blur_passes 2
      blur_radius 5
      default_dim_inactive 0.2
      dim_inactive_colors.unfocused #000000FF

      for_window [class="sway-cheatsheet"] floating enable, opacity 0.8, corner_radius 20, floating_border none, border none

      layer_effects waybar {
        corner_radius 10
        shadows enable
      }

      # Cheatsheet
      bindsym --release Mod1+F1 exec "pkill yad &"
      bindsym Mod1+F1 exec sway-cheatsheet
    '';
  };
}