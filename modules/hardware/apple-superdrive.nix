# tags: superdrive
{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.sg3_utils ];
  services.udev.extraRules = ''
    # Apple SuperDrive Initialization
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="05ac", ATTR{idProduct}=="1500", RUN+="${pkgs.sg3_utils}/bin/sg_raw /dev/%k EA 00 00 00 00 00 01"
  '';
}
