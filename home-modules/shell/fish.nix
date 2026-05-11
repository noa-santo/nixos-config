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

      function cf
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

      function pasteimg
        set name (test -n "$argv[1]"; and echo $argv[1]; or echo "clipboard.png")
        string match -q "*.png" $name; or set name "$name.png"
        wl-paste --type image/png > $name
        echo "Saved to $name"
      end

      fastfetch
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
