{ pkgs, inputs, ... }:
let
  commonPlugins = import ./lib/common-plugins.nix;
in
{
  meta = {
    binName = "go";
    ide = "goland";
    icon = "goland";
    displayName = "Goland (Go Env)";
    comment = "Start Goland with Go dev environment";
  };

  shell = pkgs.mkShell {
    packages = with inputs.nix-jetbrains-plugins.lib; [
      (buildIdeWithPlugins pkgs "goland" (commonPlugins))
      pkgs.go
      pkgs.direnv
    ];
    shellHook = ''
      echo "Go dev environment loaded."
    '';
  };
}
