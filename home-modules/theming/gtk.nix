{ config, pkgs, lib, ... }:

 {
   home.packages = with pkgs; [
     adw-gtk3
     adwaita-icon-theme
     libsForQt5.qt5ct
     qt6Packages.qt6ct
   ];

   dconf.settings = {
     "org/gnome/desktop/interface" = {
       gtk-theme = lib.mkDefault "adw-gtk3-dark";
     };
   };

   gtk = {
     enable = true;

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