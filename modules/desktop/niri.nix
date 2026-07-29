# tags: niri
{
  pkgs,
  inputs,
  lib,
  ...
}:
{
  hardware.graphics.enable = true;
  services.displayManager.gdm.enable = true;

  # niri has no CSD/no built-in polkit agent of its own; gnome-keyring +
  # polkit are already wired up by the gnome module, but make sure they're
  # available even on a niri-only host.
  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true;

  xdg.portal.config.niri = {
    "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
  };
}
