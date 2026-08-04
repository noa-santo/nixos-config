{ pkgs, ... }:
let
  base16 = {
    base00 = "#1e1e2e";
    base01 = "#181825";
    base02 = "#313244";
    base03 = "#45475a";
    base04 = "#585b70";
    base05 = "#cdd6f4";
    base06 = "#f5f5f5";
    base07 = "#ffffff";
    base08 = "#f38ba8";
    base09 = "#fab387";
    base0A = "#f9e2af";
    base0B = "#a6e3a1";
    base0C = "#94e2d5";
    base0D = "#89b4fa";
    base0E = "#cba6f7";
    base0F = "#f5e0dc";
  };

  extra = {
    crust = "#11111b";
    ov0 = "#6c7086";
    ov2 = "#9399b2";
    subtext = "#a6adc8";
    lavender = "#b4befe";
    sapphire = "#74c7ec";
    sky = "#89dceb";
    pink = "#f5c2e7";
  };
in
{
  polarity = "dark";
  colors = base16 // extra;

  image = ../../assets/wallpapers/blob.webp;
  svg = ../../assets/wallpapers/blob.svg;

  cursor = {
    name = "Bibata-Modern-Pink";
    size = 24;
    package = pkgs.stdenvNoCC.mkDerivation {
      pname = "bibata-modern-pink";
      version = "1.0";
      src = ../../assets/icons;

      installPhase = ''
        mkdir -p $out/share/icons
        cp -r Bibata-Modern-Pink $out/share/icons/
      '';
    };
  };

  fonts = {
    monospace = {
      name = "JetBrainsMono Nerd Font";
      package = pkgs.nerd-fonts.jetbrains-mono;
    };
    sansSerif = {
      name = "JetBrainsMono Nerd Font";
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
    terminal = 0.75;
    applications = 1.0;
    desktop = 0.9;
    popups = 0.98;
  };

  ui = {
    icon = "Font Awesome 6 Free";

    mako.width = 380;
    wofi = {
      windowWidth = 640;
      windowHeight = 480;
    };
    sway.outerGap = 6;

    niri.shaders = {
      window-open = ../../assets/shaders/perlin/open.glsl;
      window-close = ../../assets/shaders/perlin/close.glsl;
      window-resize = ../../assets/shaders/perlin/resize.glsl;
    };

    gnome = {
      screensaverPrimary = "#241f31";
      screensaverSecondary = "#000000";
      arcMenu = {
        background = "#262830";
        border = "rgb(60,60,60)";
        accent = "rgb(26,95,180)";
        foreground = "#e0e0e8";
        activeBackground = "#004397";
        activeForeground = "#d6e2ff";
        separator = "rgba(255,255,255,0.1)";
        radius = 25;
      };
    };

    browser.spaces = {
      opacity = 0.8;
      texture = 0.6;
      lightness = 50;
      general = {
        red = 252;
        green = 5;
        blue = 136;
      };
      tum = {
        red = 0;
        green = 150;
        blue = 250;
      };
      bivi = {
        red = 153;
        green = 2;
        blue = 229;
      };
    };
  };
}
