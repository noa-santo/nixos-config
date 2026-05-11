{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    adw-gtk3
    adwaita-icon-theme
    libsForQt5.qt5ct
    qt6Packages.qt6ct
  ];

  # Set gtk-theme via dconf.  color-scheme is already managed by gnome.nix.
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      gtk-theme = lib.mkDefault "adw-gtk3-dark";
    };
  };

  gtk = {
    enable = true;

    # Import dynamic Matugen accent colours; falls back gracefully if the file
    # does not exist yet (before the first `matugen gen` run).
    gtk3.extraCss = ''
      @import url("file://${config.home.homeDirectory}/.cache/matugen/colors-gtk.css");
    '';
    gtk4.extraCss = ''
      @import url("file://${config.home.homeDirectory}/.cache/matugen/colors-gtk.css");
    '';

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
      gtk-theme-name = "adw-gtk3-dark";
    };

    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "qt6ct";
  };
}
