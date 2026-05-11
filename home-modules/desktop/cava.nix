{ pkgs, lib, ... }:

let
  # Wrapper script: merges the static base config with Matugen's dynamic
  # colour file, then launches the real cava binary.
  cava-dynamic = pkgs.writeShellScriptBin "cava" ''
    mkdir -p ~/.config/cava
    cat ~/.config/cava/config_base ~/.config/cava/colors \
        > ~/.config/cava/config 2>/dev/null || true
    exec ${pkgs.cava}/bin/cava "$@"
  '';
in
{
  home.packages = [
    (lib.hiPrio cava-dynamic)
  ];

  xdg.configFile."cava/config_base".text = ''
    [general]
    framerate = 60
    bars = 0
    bar_width = 3
    bar_spacing = 1
    sensitivity = 75
    autosens = 1

    [smoothing]
    integral = 80
    monstercat = 1
    gravity = 120
    ignore = 0
    noise_reduction = 77

    [eq]
    1 = 1.0
    2 = 1.0
    3 = 1.1
    4 = 1.2
    5 = 1.5
  '';
}
