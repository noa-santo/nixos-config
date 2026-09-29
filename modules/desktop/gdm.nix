# no-auto-import
_: {
  services.displayManager.gdm.enable = true;

  security.pam.services.login.enableGnomeKeyring = true;
  security.pam.services.gdm-password.enableGnomeKeyring = true;
}
