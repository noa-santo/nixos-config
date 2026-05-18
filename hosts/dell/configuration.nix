{ config, pkgs, lib, ... }:

{
  imports = [
    ../../modules/all.nix
  ];

  mainUser = "owo";
  networking.hostName = "dell";

  tags = [
      "laptop"
      "gnome"
      "sway"
      "dev"
      "docker"
      "gaming"
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.xserver.xkb = {
    layout = "us";
    variant = "altgr-intl";
  };

  services.fprintd = {
    enable = true;
    package = pkgs.fprintd.override {
      libfprint = pkgs.libfprint-goodix53x5;
    };
  };
  services.udev.packages = [ pkgs.libfprint-goodix53x5 ];
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTR{idVendor}=="27c6", ATTR{idProduct}=="5385", ATTR{power/control}="on", ATTR{power/persist}="1", ENV{ID_AUTOSUSPEND}="0"
    SUBSYSTEM=="usb", ATTR{idVendor}=="27c6", ATTR{idProduct}=="5395", ATTR{power/control}="on", ATTR{power/persist}="1", ENV{ID_AUTOSUSPEND}="0"
    # Prevent cdc_acm from claiming Goodix fingerprint devices by unbinding it when present
    SUBSYSTEM=="usb", ATTR{idVendor}=="27c6", ATTR{idProduct}=="5385", RUN+="/bin/sh -c 'if [ -e /sys/bus/usb/drivers/cdc_acm/unbind ]; then echo -n $kernel > /sys/bus/usb/drivers/cdc_acm/unbind; fi'"
    SUBSYSTEM=="usb", ATTR{idVendor}=="27c6", ATTR{idProduct}=="5395", RUN+="/bin/sh -c 'if [ -e /sys/bus/usb/drivers/cdc_acm/unbind ]; then echo -n $kernel > /sys/bus/usb/drivers/cdc_acm/unbind; fi'"
    # Also unbind on interface add (match CDC interfaces) to catch cases where cdc_acm binds quickly
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="27c6", ATTRS{idProduct}=="5385", ATTRS{bInterfaceClass}=="02", RUN+="/bin/sh -c 'echo %k > /sys/bus/usb/drivers/cdc_acm/unbind 2>/dev/null || true'"
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="27c6", ATTRS{idProduct}=="5395", ATTRS{bInterfaceClass}=="02", RUN+="/bin/sh -c 'echo %k > /sys/bus/usb/drivers/cdc_acm/unbind 2>/dev/null || true'"
  '';

  # Ensure cdc_acm is unbound early at boot for any present Goodix devices
  systemd.services.unbind-goodix = {
    description = "Unbind cdc_acm from Goodix fingerprint devices";
    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-udev-trigger.service" "systemd-udevd.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "/bin/sh -c 'for dev in /sys/bus/usb/devices/*; do if [ -f \"$dev/idVendor\" ] && [ -f \"$dev/idProduct\" ]; then v=$(cat \"$dev/idVendor\"); p=$(cat \"$dev/idProduct\"); if [ \"$v\" = \"27c6\" ] && { [ \"$p\" = \"5385\" ] || [ \"$p\" = \"5395\" ]; }; then if [ -e /sys/bus/usb/drivers/cdc_acm/unbind ]; then echo -n $(basename \"$dev\") > /sys/bus/usb/drivers/cdc_acm/unbind 2>/dev/null || true; fi; fi; fi; done'";
    };
  };

  security.pam.services.login.fprintAuth = lib.mkForce true;
  security.pam.services.sudo.fprintAuth = lib.mkForce true;
  security.pam.services.gdm-fingerprint.fprintAuth = lib.mkForce true;
  security.pam.services.login.enableGnomeKeyring = true;
  security.pam.services.gdm-password.enableGnomeKeyring = true;

  system.stateVersion = "25.11";
}
