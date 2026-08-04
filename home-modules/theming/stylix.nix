_: {
  dconf.enable = true;
  home.pointerCursor.sway.enable = true;
  gtk = {
    gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
  };
  stylix.targets = {
    sway.enable = false;
    waybar.enable = false;
    wofi.enable = false;
    niri.enable = false;
    zen-browser.profileNames = [ "default" ];
  };
}
