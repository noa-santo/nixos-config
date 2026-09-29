# GDM plus the PAM/gnome-keyring wiring it needs to unlock keyrings on
# login. Every desktop module that turns on gdm (sway, niri, gnome)
# imports this instead of repeating `services.displayManager.gdm.enable`
# and re-declaring the PAM lines per host.
_: {
  services.displayManager.gdm.enable = true;

  security.pam.services.login.enableGnomeKeyring = true;
  security.pam.services.gdm-password.enableGnomeKeyring = true;
}
