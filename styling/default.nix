{
  config,
  lib,
  pkgs,
  hostTags,
  ...
}:

let
  themeFile = import ./styles/${config.styling.name}.nix { inherit pkgs lib hostTags; };
  c = themeFile.colors;

  requiredThemeSections = [
    [ "colors" ]
    [ "polarity" ]
    [ "image" ]
    [ "svg" ]
    [ "cursor" ]
    [ "icon" ]
    [ "fonts" ]
    [ "opacity" ]
  ];

  scheme = {
    name = config.styling.name;
    slug = config.styling.name;
  }
  // (lib.filterAttrs (n: _: lib.hasPrefix "base" n) c);

  palette = {
    base = c.base00;
    mantle = c.base01;
    crust = c.crust or c.base02;
    s0 = c.base03;
    s1 = c.base04;
    s2 = c.base05;
    text = c.base05;
    subtext = c.subtext or c.base04;
    ov0 = c.ov0 or c.base03;
    ov2 = c.ov2 or c.base04;
    red = c.base08;
    peach = c.base09;
    yellow = c.base0A;
    green = c.base0B;
    teal = c.base0C;
    blue = c.base0D;
    mauve = c.base0E;
    rosewater = c.base0F;
    lavender = c.lavender or c.base0E;
    sapphire = c.sapphire or c.base0D;
    sky = c.sky or c.base0C;
    pink = c.pink or c.base0F;
  };

  designTokens = {
    font = themeFile.fonts.monospace.name;
    transparent = "transparent";
    dim = "#000000FF";
    gap = 8;
    cornerRadius = 12;
    borderWidth = 2;

    radius = {
      xs = 6;
      sm = 8;
      md = 10;
      lg = 14;
      xl = 16;
    };
    spacing = {
      xs = 4;
      sm = 8;
      md = 12;
      lg = 16;
      xl = 20;
    };
    opacity = {
      subtle = 0.15;
      hairline = 0.2;
      faint = 0.3;
      low = 0.4;
      mid = 0.5;
      high = 0.8;
      solid = 0.92;
      nearOpaque = 0.98;
      full = 1.0;
    };
    fontSize = {
      xs = 11;
      sm = 12;
      md = 13;
      lg = 15;
      xl = 16;
    };
    transition = "200ms ease";
    transitionFast = "150ms ease";
    animation = {
      duration = 500;
      curve = "ease-out-cubic";
      pulse = "1s linear infinite";
    };
    shadow = {
      color = "#00000066";
      blur = 20;
      passes = 3;
      spread = 5;
    };

    effects = {
      blur = true;
      shadow = true;
    };
  };

  theme = themeFile // {
    inherit scheme palette;
    ui = designTokens // (themeFile.ui or { });
  };
in
{
  options.styling = {
    name = lib.mkOption {
      type = lib.types.str;
      default = "vibrant-wave";
      description = "Named theme in styling/styles/.";
    };

    theme = lib.mkOption {
      type = lib.types.attrs;
      internal = true;
      readOnly = true;
      description = "Resolved theme (see styling/styles/${config.styling.name}.nix).";
    };
  };

  config = {
    assertions = map (path: {
      assertion = lib.hasAttrByPath path themeFile;
      message = "Theme `${config.styling.name}` is missing required field `${lib.concatStringsSep "." path}`.";
    }) requiredThemeSections;

    styling.theme = theme;

    stylix = {
      enable = true;
      enableReleaseChecks = false;
      autoEnable = true;
      overlays.enable = true;
      base16Scheme = theme.scheme;
      inherit (theme) polarity;
      inherit (theme) image;
      inherit (theme) cursor;
      inherit (theme) fonts;
      inherit (theme) opacity;

      icons = {
        enable = true;
        package = theme.icon.package;
        dark = theme.icon.dark or theme.icon.name;
        light = theme.icon.light or theme.icon.dark or theme.icon.name;
      };
    };
  };
}
