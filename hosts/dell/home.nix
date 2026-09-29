{ lib, ... }:
{
  wayland.windowManager.sway = {
    config = {
      output."*".scale = lib.mkForce "2";
    };
  };
}
