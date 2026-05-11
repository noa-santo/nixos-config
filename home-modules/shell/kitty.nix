{ pkgs, ... }:

{
  programs.kitty = {
    enable = true;
    package = pkgs.kitty;

    settings = {
      enable_wayland = "yes";
      hide_window_decorations = "no";
      confirm_os_window_close = 1;

      shell = "${pkgs.fish}/bin/fish";

      font_family = "JetBrains Mono";
      font_size = "11.0";
      # Keep the frosted-glass look
      background_opacity = "0.75";
      window_padding_width = 4;

      tab_title_template = "{title}";
      tab_bar_style = "powerline";

      scrollback_lines = 10000;

      # Cursor trail effect
      cursor_trail = 1;

      enable_audio_bell = "no";
    };

    # Matugen writes terminal colours to /tmp/kitty-matugen-colors.conf.
    # Including it last means those colours override any earlier defaults while
    # background_opacity (frosted effect) is unaffected — it is a separate
    # window-compositor setting.
    extraConfig = ''
      include /tmp/kitty-matugen-colors.conf
    '';

    keybindings = {
      "ctrl+shift+enter" = "new_window";
      "ctrl+shift+t" = "new_tab";
      "ctrl+shift+w" = "close_window";
    };
  };
}
