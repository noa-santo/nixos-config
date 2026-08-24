# tags: niri
{
  pkgs,
  osConfig,
  ...
}:

let
  c = osConfig.styling.theme.palette;

  # Directory where screenshots will be saved
  screenshotDir = "$HOME/Pictures/Screenshots";
  filenameFormat = "%Y-%m-%d_%H-%M-%S.png";

  screenshotAnnotateScript = pkgs.writeShellScriptBin "niri-screenshot-annotate" ''
    #!/bin/sh
    mkdir -p "${screenshotDir}"

    file="${screenshotDir}/${filenameFormat}"

    grim -g "$(slurp)" - | satty --filename - --output-filename "$file"

    if [ -s "$file" ]; then
      wl-copy --type image/png < "$file"
      notify-send "Screenshot annotated and copied to clipboard" -t 2000
    else
      rm -f "$tmp_file"
    fi
  '';
in
{
  home.packages = with pkgs; [
    satty
    screenshotAnnotateScript
  ];

  programs.satty = {
    enable = true;
    settings = {
      general = {
        fullscreen = false;
        early-exit = true;
        initial-tool = "brush";
        copy-command = "wl-copy";
        annotation-size-factor = 2;
        output-filename = "${screenshotDir}/${filenameFormat}";
      };
      color-palette = {
        custom = [
          c.mauve
          c.red
          c.blue
          c.green
        ];
      };
    };
  };

  programs.niri.settings.binds = {
    "Ctrl+Print".action.spawn = "${screenshotAnnotateScript}/bin/niri-screenshot-annotate";
  };
}
