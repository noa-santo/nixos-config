{
  inputs,
  pkgs,
  lib,
  hostTags ? [ ],
  ...
}:
let
  isNiri = builtins.elem "niri" hostTags;
in
{
  imports = [
    inputs.vicinae.homeManagerModules.default
  ];

  programs.vicinae = {
    enable = true;
    package = pkgs.vicinae;
    systemd = {
      enable = true;
      autoStart = true;
      environment = {
        USE_LAYER_SHELL = 1;
      };
    };
    settings = {
      close_on_focus_loss = true;
      consider_preedit = true;
      pop_to_root_on_close = true;
      favicon_service = "twenty";
      search_files_in_root = true;
    };
    extensions =
      with inputs.vicinae-extensions.packages.${pkgs.stdenv.hostPlatform.system};
      [
        # bluetooth temp disabled till fixed todo
        nix
        power-profile
        color-converter
        github
        port-killer
        wifi-commander
        process-manager
        wikipedia
        player-pilot
        it-tools
        inputs.emojidb-extension.packages.${pkgs.stdenv.hostPlatform.system}.default
      ]
      ++ lib.optionals isNiri [ niri ];
  };
}
