{ lib, pkgs, ... }:
{
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
