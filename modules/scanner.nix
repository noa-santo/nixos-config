# tags: scanner
{ pkgs, modulesPath, config, ... }:
{
  imports = [
    (modulesPath + "/services/hardware/sane_extra_backends/brscan4.nix")
  ];

  hardware = {
      sane = {
        enable = true;
        extraBackends = [ pkgs.sane-airscan ];
        brscan4 = {
          enable = true;
        };
      };
    };
  services.ipp-usb.enable = true;
  users.users.${config.mainUser}.extraGroups = [ "scanner" "lp" ];
}