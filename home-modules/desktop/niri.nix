# tags: niri
{ pkgs, lib, config, inputs, hostTags, ... }:

let
  isKdeConnect = builtins.elem "kde-connect" hostTags;

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

  screenshotScript = pkgs.writeShellScriptBin "niri-screenshot" ''
    #!/bin/sh
    grim - | wl-copy --type image/png
    notify-send "Screenshot copied to clipboard" -t 2000
  '';

  screenshotSelectScript = pkgs.writeShellScriptBin "niri-screenshot-select" ''
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
    swaybg
    fuzzel
    wl-clipboard
    mako
    waybar
    pavucontrol
    yad
    btop
    networkmanagerapplet
    nerd-fonts.jetbrains-mono
    font-awesome
    screenshotScript
    screenshotSelectScript
    librsvg
    xwayland-satellite
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

  services.swayosd = {
    enable    = true;
    topMargin = 0.9;
  };

  programs.niri.package = pkgs.niri-stable;
  programs.niri.settings = {
    input = {
      keyboard.xkb = {};
      touchpad = {
        tap              = true;
        dwt              = true;
        natural-scroll   = true;
        middle-emulation = true;
        scroll-method    = "two-finger";
      };
      mouse.natural-scroll = true;
      focus-follows-mouse = {
        enable = true;
        max-scroll-amount = "100%";
      };
    };

    cursor.theme = "Bibata-Modern-Pink";

    prefer-no-csd = true;

    hotkey-overlay.skip-at-startup = true;

    layout = {
      gaps = 8;
      border = {
        enable   = true;
        width    = 2;
        active   = { color = c.mauve; };
        inactive = { color = c.s0; };
        urgent   = { color = c.red; };
      };
      focus-ring.enable  = false;
      background-color   = c.base;
      shadow.enable      = true;
      shadow.color       = "#00000066";
    };

    window-rules = [
      {
        matches = [{ }];
        geometry-corner-radius = {
          top-left = 12.0; top-right = 12.0;
          bottom-left = 12.0; bottom-right = 12.0;
        };
        clip-to-geometry = true;
      }
      {
        matches = [{ app-id = "^zen-beta$"; }];
        open-on-workspace = "browser";
      }
      {
        matches = [
          { app-id = "^jetbrains-idea$"; }
          { app-id = "^jetbrains-pycharm$"; }
          { app-id = "^jetbrains-clion"; }
          { app-id = "^jetbrains-webstorm"; }
        ];
        open-on-workspace = "ide";
      }
      {
        matches = [
          { app-id = "^discord$"; }
          { app-id = "^signal$"; }
        ];
        open-on-workspace = "social";
      }
      {
        matches = [
          { app-id = "^kitty$"; }
        ];
        open-on-workspace = "terminal";
        background-effect = {
          blur = true;
        };
      }
    ];

    layer-rules = [
      {
        matches = [{ namespace = "^waybar$"; }];
        geometry-corner-radius = {
          top-left = 12.0; top-right = 12.0;
          bottom-left = 12.0; bottom-right = 12.0;
        };
        shadow.enable = true;
      }
      {
        matches = [{ namespace = "^notifications$"; }];
        geometry-corner-radius = {
          top-left = 10.0; top-right = 10.0;
          bottom-left = 10.0; bottom-right = 10.0;
        };
        shadow.enable = true;
      }
    ];

    spawn-at-startup = [
      { argv = [ "swaybg" "--image" "${config.home.homeDirectory}/.config/nixos-config/assets/wallpapers/blob.webp" "--mode" "fill" ]; }
      { argv = [ "vicinae" "server" "--replace" ]; }
      { argv = [ "${config.home.homeDirectory}/.config/waybar/scripts/launch.sh" ]; }
    ] ++ lib.optionals (isKdeConnect) [
      { argv = [ "kdeconnectd" ]; }
    ];

    animations = {
      window-open = {
        kind.easing = {
          duration-ms = 500;
          curve = "ease-out-cubic";
        };
        custom-shader = builtins.readFile ../../assets/shaders/perlin/open.glsl;
      };
      window-close = {
        kind.easing = {
          duration-ms = 500;
          curve = "ease-out-cubic";
        };
        custom-shader = builtins.readFile ../../assets/shaders/perlin/close.glsl;
      };
      window-resize = {
        kind.easing = {
          duration-ms = 500;
          curve = "ease-out-cubic";
        };
        custom-shader = builtins.readFile ../../assets/shaders/perlin/resize.glsl;
      };
    };

    workspaces = {
      "terminal" = {};
      "social" = {};
      "ide" = {};
      "browser" = {};
    };

    binds = {
      "Mod+Shift+Slash".action.show-hotkey-overlay = [ ];

      "Mod+D".action.spawn       = [ "vicinae" "open" ];
      "Mod+Shift+D".action.spawn = [ "fuzzel" ];
      "Mod+Return".action.spawn   = [ "kitty" ];

      # Screenshots
      "Print".action.spawn       = "${screenshotScript}/bin/niri-screenshot";
      "Shift+Print".action.spawn = "${screenshotSelectScript}/bin/niri-screenshot-select";

      # Brightness
      "XF86MonBrightnessUp".action.spawn   = [ "swayosd-client" "--brightness" "raise" ];
      "XF86MonBrightnessDown".action.spawn = [ "swayosd-client" "--brightness" "lower" ];

      # Volume
      "XF86AudioRaiseVolume".action.spawn = [ "swayosd-client" "--output-volume" "raise" ];
      "XF86AudioLowerVolume".action.spawn = [ "swayosd-client" "--output-volume" "lower" ];
      "XF86AudioMute".action.spawn        = [ "swayosd-client" "--output-volume" "mute-toggle" ];
      "XF86AudioMicMute".action.spawn     = [ "swayosd-client" "--input-volume" "mute-toggle" ];

      # Media
      "XF86AudioPlay".action.spawn = [ "playerctl" "play-pause" ];
      "XF86AudioNext".action.spawn = [ "playerctl" "next" ];
      "XF86AudioPrev".action.spawn = [ "playerctl" "previous" ];

      # Window / column navigation
      "Mod+Shift+Q".action.close-window = [ ];

      "Mod+Left".action.focus-column-left   = [ ];
      "Mod+Down".action.focus-window-down   = [ ];
      "Mod+Up".action.focus-window-up       = [ ];
      "Mod+Right".action.focus-column-right = [ ];
      "Mod+H".action.focus-column-left      = [ ];
      "Mod+J".action.focus-window-down      = [ ];
      "Mod+K".action.focus-window-up        = [ ];
      "Mod+L".action.focus-column-right     = [ ];

      "Mod+Shift+Left".action.move-column-left   = [ ];
      "Mod+Shift+Down".action.move-window-down   = [ ];
      "Mod+Shift+Up".action.move-window-up       = [ ];
      "Mod+Shift+Right".action.move-column-right = [ ];
      "Mod+Shift+H".action.move-column-left      = [ ];
      "Mod+Shift+J".action.move-window-down      = [ ];
      "Mod+Shift+K".action.move-window-up        = [ ];
      "Mod+Shift+L".action.move-column-right     = [ ];

      "Mod+Ctrl+Left".action.consume-or-expel-window-left   = [ ];
      "Mod+Ctrl+Right".action.consume-or-expel-window-right = [ ];
      "Mod+Ctrl+H".action.consume-or-expel-window-left      = [ ];
      "Mod+Ctrl+L".action.consume-or-expel-window-right     = [ ];

      "Mod+Home".action.focus-column-first      = [ ];
      "Mod+End".action.focus-column-last        = [ ];
      "Mod+Shift+Home".action.move-column-to-first = [ ];
      "Mod+Shift+End".action.move-column-to-last   = [ ];

      "Mod+1".action.focus-workspace = "browser";
      "Mod+2".action.focus-workspace = "ide";
      "Mod+3".action.focus-workspace = "social";
      "Mod+4".action.focus-workspace = "terminal";
      "Mod+5".action.focus-workspace = 5;
      "Mod+6".action.focus-workspace = 6;
      "Mod+7".action.focus-workspace = 7;
      "Mod+8".action.focus-workspace = 8;
      "Mod+9".action.focus-workspace = 9;
      "Mod+0".action.focus-workspace = 10;

      "Mod+Shift+1".action.move-column-to-workspace = "browser";
      "Mod+Shift+2".action.move-column-to-workspace = "ide";
      "Mod+Shift+3".action.move-column-to-workspace = "social";
      "Mod+Shift+4".action.move-column-to-workspace = "terminal";
      "Mod+Shift+5".action.move-column-to-workspace = 5;
      "Mod+Shift+6".action.move-column-to-workspace = 6;
      "Mod+Shift+7".action.move-column-to-workspace = 7;
      "Mod+Shift+8".action.move-column-to-workspace = 8;
      "Mod+Shift+9".action.move-column-to-workspace = 9;
      "Mod+Shift+0".action.move-column-to-workspace = 10;

      "Mod+Page_Down".action.focus-workspace-down = [ ];
      "Mod+Page_Up".action.focus-workspace-up     = [ ];

      "Mod+Comma".action.consume-window-into-column = [ ];
      "Mod+Period".action.expel-window-from-column  = [ ];

      "Mod+R".action.switch-preset-column-width       = [ ];
      "Mod+Shift+R".action.switch-preset-column-width-back = [ ];
      "Mod+F".action.maximize-column        = [ ];
      "Mod+Shift+F".action.fullscreen-window = [ ];
      "Mod+V".action.toggle-window-floating  = [ ];
      "Mod+W".action.toggle-column-tabbed-display = [ ];
      "Mod+O".action.toggle-overview         = [ ];

      "Mod+Shift+E".action.quit = [ ];
    };
  };
}
