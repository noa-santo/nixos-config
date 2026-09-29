# tags: dev
{
  pkgs,
  inputs,
  lib,
  ...
}:
let
  devEnvironments = import ../../lib/dev-environments.nix {
    inherit pkgs inputs lib;
    devShellsDir = ../../dev-shells;
  };

  mkDesktopItem =
    e:
    pkgs.makeDesktopItem {
      name = "${e.binName}-ide";
      exec = "${e.binName}-ide";
      icon = e.icon;
      desktopName = e.displayName;
      comment = e.comment;
      categories = [ "Development" ];
    };
in
{
  home.packages = map mkDesktopItem devEnvironments;
}
