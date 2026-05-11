{ lib, pkgs, ... }:
{
  home.packages = with pkgs; [
    fzf
    bat
    fastfetch
    wl-clipboard
    jq
  ];

  programs.fish = {
    enable = true;
    plugins = [
      { name = "grc"; src = pkgs.fishPlugins.grc.src; }
      { name = "tide";           src = pkgs.fishPlugins.tide.src; }
      { name = "autopair.fish";  src = pkgs.fishPlugins.autopair.src; }
      { name = "puffer-fish";    src = pkgs.fishPlugins.puffer.src; }
      { name = "done";           src = pkgs.fishPlugins.done.src; }
    ];
    interactiveShellInit = ''
      set fish_greeting
      pay-respects fish --alias | source

      # ── qcopy: fzf-select files and copy contents to clipboard ──────────────
      function qcopy
        if not command -v wl-copy &>/dev/null
          echo "Error: wl-copy not found (install wl-clipboard)"
          return 1
        end
        if not command -v fzf &>/dev/null
          echo "Error: fzf not found"
          return 1
        end

        set preview_cmd "cat {}"
        if command -v bat &>/dev/null
          set preview_cmd "bat --style=numbers --color=always {}"
        end

        set selected (find . -type f -not -path "*/\.git/*" 2>/dev/null | fzf --multi \
          --layout=reverse \
          --preview=$preview_cmd \
          --preview-window="right:60%:wrap" \
          --prompt="Select files > " \
          --header="TAB=select  ENTER=copy  ESC=cancel")

        if test -z "$selected"
          echo "No files selected."
          return 0
        end

        set tmp (mktemp)
        for f in $selected
          set clean (string replace -r '^\./' "" $f)
          echo "file name: $clean" >> $tmp
          echo "file contents:" >> $tmp
          cat $f >> $tmp
          printf '\n----------------------------------------\n\n' >> $tmp
        end
        cat $tmp | wl-copy
        echo "Copied "(count $selected)" file(s) to clipboard."
        rm -f $tmp
      end

      # ── pasteimg: save clipboard image to a PNG file ─────────────────────────
      function pasteimg
        set name (test -n "$argv[1]"; and echo $argv[1]; or echo "clipboard.png")
        string match -q "*.png" $name; or set name "$name.png"
        wl-paste --type image/png > $name
        echo "Saved to $name"
      end

      # ── fetch: dynamic matugen-coloured fastfetch ────────────────────────────
      function fetch
        set color_file /tmp/qs_colors.json
        set config_path /tmp/qs_fastfetch.jsonc
        set palette_file /tmp/qs_palette

        # Rebuild only when the colour file is newer than the cached config
        if test $color_file -nt $config_path 2>/dev/null; or not test -f $config_path

          # Parse all colours in one jq pass; fall back to Catppuccin Mocha
          if test -f $color_file
            set parsed (jq -r '[
              .blue     // "#89b4fa",
              .sapphire // "#74c7ec",
              .teal     // "#94e2d5",
              .mauve    // "#cba6f7",
              .text     // "#cdd6f4",
              .red      // "#f38ba8",
              .peach    // "#fab387",
              .yellow   // "#f9e2af",
              .green    // "#a6e3a1",
              .pink     // "#f5c2e7"
            ] | .[]' $color_file 2>/dev/null)
          end

          if test -z "$parsed"
            set parsed "#89b4fa" "#74c7ec" "#94e2d5" "#cba6f7" "#cdd6f4" \
                       "#f38ba8" "#fab387" "#f9e2af" "#a6e3a1" "#f5c2e7"
          end

          set c_blue     $parsed[1]
          set c_sapphire $parsed[2]
          set c_teal     $parsed[3]
          set c_mauve    $parsed[4]
          set c_text     $parsed[5]
          set palette_hexes $parsed[6] $parsed[7] $parsed[8] $parsed[9] $parsed[2] $parsed[4] $parsed[10]

          # Build ANSI colour palette strip → /tmp/qs_palette
          printf "" > $palette_file
          for val in $palette_hexes
            set hex (string replace "#" "" $val)
            set r (math "0x"(string sub -l 2 $hex))
            set g (math "0x"(string sub -s 3 -l 2 $hex))
            set b (math "0x"(string sub -s 5 $hex))
            printf '\033[38;2;%d;%d;%dm● \033[0m' $r $g $b >> $palette_file
          end
          printf '\n' >> $palette_file

          # Write the Fastfetch JSON config
          printf '{
  "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/master/doc/json_schema.json",
  "logo": {
    "source": "nixos_small",
    "color": { "1": "%s", "2": "%s" },
    "padding": { "top": 1, "left": 2, "right": 3 }
  },
  "display": {
    "separator": "  ",
    "color": { "separator": "%s" }
  },
  "modules": [
    "break",
    { "type": "title", "format": "{1}", "color": { "user": "%s" } },
    "break",
    { "type": "os",     "key": " os ",  "keyColor": "%s" },
    { "type": "cpu",    "key": " cpu",  "keyColor": "%s" },
    { "type": "memory", "key": " ram",  "keyColor": "%s" },
    { "type": "shell",  "key": " sh ",  "keyColor": "%s" },
    "break",
    { "type": "command", "key": " ", "text": "cat /tmp/qs_palette" }
  ]
}\n' \
            $c_blue $c_sapphire \
            $c_text \
            $c_blue \
            $c_blue $c_sapphire $c_teal $c_mauve \
            > $config_path
        end

        fastfetch -c $config_path
      end

      fetch
    '';
  };

  home.activation.configure-tide = lib.hm.dag.entryAfter ["writeBoundary"] ''
    ${pkgs.fish}/bin/fish -c "set fish_function_path ${pkgs.fishPlugins.tide.src}/functions \$fish_function_path; tide configure --auto --style=Rainbow --prompt_colors='True color' --show_time='24-hour format' --rainbow_prompt_separators=Slanted --powerline_prompt_heads=Sharp --powerline_prompt_tails=Slanted --powerline_prompt_style='Two lines, character and frame' --prompt_connection=Dotted --powerline_right_prompt_frame=Yes --prompt_connection_andor_frame_color=Dark --prompt_spacing=Sparse --icons='Many icons' --transient=Yes"
  '';

  programs.bash = {
    initExtra = ''
      if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
      then
        shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
        exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
      fi
    '';
  };
}
