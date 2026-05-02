{ pkgs, inputs, config, lib, ... }:

let
  cfg = config.tags;
in
{
  config = lib.mkIf (builtins.elem "sway" cfg) {
    hardware.graphics.enable = true;
    services.displayManager.gdm.enable = true;
    services.displayManager.gdm.wayland = true;
    programs.sway.enable = true;
  };
}
