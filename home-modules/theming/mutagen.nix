{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    matugen
  ];
  # Symlink the matugen config directory out-of-store so templates can be
  # re-used without a rebuild (just run `matugen gen <wallpaper>`).
  xdg.configFile."matugen".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/nixos-config/home-modules/matugen";
}