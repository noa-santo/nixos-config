# tags: niri
{
  pkgs,
  lib,
  config,
  osConfig,
  hostTags,
  inputs,
  ...
}:

let
  isKdeConnect = builtins.elem "kde-connect" hostTags;

  c = osConfig.styling.theme.palette;
  u = osConfig.styling.theme.ui;

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

  wavepaper = pkgs.buildGoModule {
    pname = "wavepaper";
    version = "0.1.1";
    src = pkgs.fetchFromGitHub {
      owner = "noa-santo";
      repo = "wavepaper";
      rev = "919298196efbe33a7ca32d0712a336c52b58d01d";
      hash = "sha256-iEbYPvA8iwtFv+eEsRiDZXyWngLAptcsM1m54jt/GyE=";
    };
    vendorHash = "sha256-PkX/1LBBQMI8mavbpLeBD5Pmn0t3Vs0sM3l/QrGsZjk=";
    nativeBuildInputs = [ pkgs.librsvg ];
  };

  geometry-corner-radius = {
    top-left = u.cornerRadius + 0.0;
    top-right = u.cornerRadius + 0.0;
    bottom-left = u.cornerRadius + 0.0;
    bottom-right = u.cornerRadius + 0.0;
  };

  mkNiriAnim = shaderPath: {
    kind.easing = {
      duration-ms = u.animation.duration;
      curve = u.animation.curve;
    };
    custom-shader = builtins.readFile shaderPath;
  };
  niriAnimations = {
    window-open = mkNiriAnim u.niri.shaders.window-open;
    window-close = mkNiriAnim u.niri.shaders.window-close;
    window-resize = mkNiriAnim u.niri.shaders.window-resize;
  };
in
{
  imports = [
    inputs.niri-sidebar.homeModules.default
  ];

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
    wavepaper
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

  services.swayosd = {
    enable = true;
    topMargin = 0.9;
  };

  programs = {
    niri-sidebar = {
      enable = true;
      settings = {
        geometry = {
          width = 500;
          height = 400;
          gap = 10;
        };
        margins = {
          top = 100;
          right = 10;
          left = 10;
          bottom = 60;
        };
        interaction = {
          position = "right";
          peek = 10;
          focus_peek = 50;
          sticky = true;
        };
        window_rule = [
          {
            app_id = "^zen-beta$";
            title = "^Picture-in-Picture$";
            width = 534;
            height = 300;
            auto_add = true;
          }
        ];
      };
    };

    niri.package = pkgs.niri-stable;
    niri.settings = {
      outputs = {
        "Philips Consumer Electronics Company PHL BDM4065 0x00000990" = {
          enable = true;
          mode = {
            height = 1440;
            width = 2560;
            refresh = 59.951;
          };
          variable-refresh-rate = true;
        };
      };

      input = {
        keyboard.xkb = { };
        touchpad = {
          tap = true;
          dwt = true;
          natural-scroll = true;
          middle-emulation = true;
          scroll-method = "two-finger";
        };
        mouse.natural-scroll = false;
        focus-follows-mouse = {
          enable = true;
          max-scroll-amount = "100%";
        };
      };

      cursor.theme = osConfig.styling.theme.cursor.name;

      prefer-no-csd = true;

      hotkey-overlay.skip-at-startup = true;

      layout = {
        gaps = u.gap;
        border = {
          enable = true;
          width = u.borderWidth;
          active = {
            color = c.mauve;
          };
          inactive = {
            color = c.s0;
          };
          urgent = {
            color = c.red;
          };
        };
        focus-ring.enable = false;
        background-color = "transparent";
        shadow.enable = true;
        shadow.color = u.shadow.color;
      };

      window-rules = [
        {
          matches = [ { } ];
          inherit geometry-corner-radius;
          clip-to-geometry = true;
        }
        {
          matches = [ { is-floating = true; } ];
          min-width = 100;
          min-height = 100;
        }
        {
          matches = [ { app-id = "^zen-beta$"; } ];
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
          matches = [ { namespace = "^wavepaper$"; } ];
          place-within-backdrop = true;
        }
        {
          matches = [ { namespace = "^waybar$"; } ];
          inherit geometry-corner-radius;
          shadow.enable = true;
          background-effect = {
            blur = true;
          };
        }
        {
          matches = [ { namespace = "^notifications$"; } ];
          inherit geometry-corner-radius;
          shadow.enable = true;
          background-effect = {
            blur = true;
          };
        }
      ];

      spawn-at-startup = [
        {
          argv = [
            "niri-sidebar"
            "listen"
          ];
        }
        {
          argv = [
            "wavepaper"
            "--svg"
            "${osConfig.styling.theme.svg}"
            "--wave-amplitude"
            "12"
            "--wave-speed"
            "0.1"
          ];
        }
        {
          argv = [
            "vicinae"
            "server"
            "--replace"
          ];
        }
        {
          argv = [
            "niri-screen-time"
            "-daemon"
          ];
        }
        { argv = [ "${config.home.homeDirectory}/.config/waybar/scripts/launch.sh" ]; }
      ]
      ++ lib.optionals isKdeConnect [
        { argv = [ "kdeconnectd" ]; }
      ];

      animations = niriAnimations;

      workspaces = {
        "terminal" = { };
        "social" = { };
        "ide" = { };
        "browser" = { };
      };

      binds = {
        "Mod+Shift+Slash".action.show-hotkey-overlay = [ ];

        "Mod+D".action.spawn = [
          "vicinae"
          "open"
        ];
        "Mod+Shift+D".action.spawn = [ "fuzzel" ];
        "Mod+Return".action.spawn = [ "kitty" ];

        # Niri Sidebar binds
        "Mod+S".action.spawn = [
          "niri-sidebar"
          "toggle-window"
        ];
        "Mod+Shift+S".action.spawn = [
          "niri-sidebar"
          "toggle-visibility"
        ];
        "Mod+Ctrl+S".action.spawn = [
          "niri-sidebar"
          "flip"
        ];
        "Mod+Alt+R".action.spawn = [
          "niri-sidebar"
          "reorder"
        ];

        # Screenshots
        "Print".action.spawn = "${screenshotScript}/bin/niri-screenshot";
        "Shift+Print".action.spawn = "${screenshotSelectScript}/bin/niri-screenshot-select";

        # Brightness
        "XF86MonBrightnessUp".action.spawn = [
          "swayosd-client"
          "--brightness"
          "raise"
        ];
        "XF86MonBrightnessDown".action.spawn = [
          "swayosd-client"
          "--brightness"
          "lower"
        ];

        # Volume
        "XF86AudioRaiseVolume".action.spawn = [
          "swayosd-client"
          "--output-volume"
          "raise"
        ];
        "XF86AudioLowerVolume".action.spawn = [
          "swayosd-client"
          "--output-volume"
          "lower"
        ];
        "XF86AudioMute".action.spawn = [
          "swayosd-client"
          "--output-volume"
          "mute-toggle"
        ];
        "XF86AudioMicMute".action.spawn = [
          "swayosd-client"
          "--input-volume"
          "mute-toggle"
        ];

        # Media
        "XF86AudioPlay".action.spawn = [
          "playerctl"
          "play-pause"
        ];
        "XF86AudioNext".action.spawn = [
          "playerctl"
          "next"
        ];
        "XF86AudioPrev".action.spawn = [
          "playerctl"
          "previous"
        ];

        # Window / column navigation
        "Mod+Shift+Q".action.close-window = [ ];

        "Mod+Left".action.focus-column-left = [ ];
        "Mod+Down".action.focus-window-down = [ ];
        "Mod+Up".action.focus-window-up = [ ];
        "Mod+Right".action.focus-column-right = [ ];
        "Mod+H".action.focus-column-left = [ ];
        "Mod+J".action.focus-window-down = [ ];
        "Mod+K".action.focus-window-up = [ ];
        "Mod+L".action.focus-column-right = [ ];

        "Mod+Shift+Left".action.move-column-left = [ ];
        "Mod+Shift+Down".action.move-window-down = [ ];
        "Mod+Shift+Up".action.move-window-up = [ ];
        "Mod+Shift+Right".action.move-column-right = [ ];
        "Mod+Shift+H".action.move-column-left = [ ];
        "Mod+Shift+J".action.move-window-down = [ ];
        "Mod+Shift+K".action.move-window-up = [ ];
        "Mod+Shift+L".action.move-column-right = [ ];

        "Mod+Ctrl+Left".action.consume-or-expel-window-left = [ ];
        "Mod+Ctrl+Right".action.consume-or-expel-window-right = [ ];
        "Mod+Ctrl+H".action.consume-or-expel-window-left = [ ];
        "Mod+Ctrl+L".action.consume-or-expel-window-right = [ ];

        "Mod+Home".action.focus-column-first = [ ];
        "Mod+End".action.focus-column-last = [ ];
        "Mod+Shift+Home".action.move-column-to-first = [ ];
        "Mod+Shift+End".action.move-column-to-last = [ ];

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
        "Mod+Page_Up".action.focus-workspace-up = [ ];

        "Mod+Comma".action.consume-window-into-column = [ ];
        "Mod+Period".action.expel-window-from-column = [ ];

        "Mod+R".action.switch-preset-column-width = [ ];
        "Mod+Shift+R".action.switch-preset-column-width-back = [ ];
        "Mod+F".action.maximize-column = [ ];
        "Mod+Shift+F".action.fullscreen-window = [ ];
        "Mod+V".action.toggle-window-floating = [ ];
        "Mod+W".action.toggle-column-tabbed-display = [ ];
        "Mod+O".action.toggle-overview = [ ];

        "Mod+Shift+E".action.quit = [ ];
      };
    };
  };
}
