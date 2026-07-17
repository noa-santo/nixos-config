# tags: dev
{ pkgs, inputs, lib, ... }:
let
  pythonEnv = pkgs.writeShellScriptBin "python-env" ''
    exec nix develop $HOME/.config/nixos-config#python --command ${pkgs.fish}/bin/fish
  '';
  pythonIDE = pkgs.writeShellScriptBin "python-ide" ''
    exec nix develop $HOME/.config/nixos-config#python --command pycharm "$@"
  '';
  vlangEnv = pkgs.writeShellScriptBin "vlang-env" ''
    exec nix develop $HOME/.config/nixos-config#vlang --command ${pkgs.fish}/bin/fish
  '';
  vlangIDE = pkgs.writeShellScriptBin "vlang-ide" ''
    exec nix develop $HOME/.config/nixos-config#vlang --command clion "$@"
  '';
  typescriptEnv = pkgs.writeShellScriptBin "typescript-env" ''
    exec nix develop $HOME/.config/nixos-config#typescript --command ${pkgs.fish}/bin/fish
  '';
  typescriptIDE = pkgs.writeShellScriptBin "typescript-ide" ''
    exec nix develop $HOME/.config/nixos-config#typescript --command webstorm "$@"
  '';
  minecraftModEnv = pkgs.writeShellScriptBin "minecraft-mods-env" ''
    exec nix develop $HOME/.config/nixos-config#minecraft-mods --command ${pkgs.fish}/bin/fish
  '';
  minecraftModIDE = pkgs.writeShellScriptBin "minecraft-mods-ide" ''
    exec nix develop $HOME/.config/nixos-config#minecraft-mods --command idea "$@"
  '';
  goEnv = pkgs.writeShellScriptBin "go-env" ''
    exec nix develop $HOME/.config/nixos-config#golang --command ${pkgs.fish}/bin/fish
  '';
  goIDE = pkgs.writeShellScriptBin "go-ide" ''
    exec nix develop $HOME/.config/nixos-config#golang --command goland "$@"
  '';

  jetbrainsPlugins = inputs.nix-jetbrains-plugins.lib.pluginsForIde pkgs pkgs.jetbrains.idea [
    "com.github.copilot"
  ];
in {
  environment.systemPackages = with pkgs; [
    (jetbrains.plugins.addPlugins jetbrains.idea (lib.attrValues jetbrainsPlugins))
    pythonEnv
    pythonIDE
    vlangEnv
    vlangIDE
    typescriptEnv
    typescriptIDE
    minecraftModEnv
    minecraftModIDE
    goEnv
    goIDE
  ];
}
