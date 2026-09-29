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

  mkEnvScript =
    e:
    pkgs.writeShellScriptBin "${e.binName}-env" ''
      exec nix develop $HOME/.config/nixos-config#${e.name} --command ${pkgs.fish}/bin/fish
    '';

  mkIdeScript =
    e:
    pkgs.writeShellScriptBin "${e.binName}-ide" ''
      exec nix develop $HOME/.config/nixos-config#${e.name} --command ${e.ide} "$@"
    '';

  commonPlugins = import ../../dev-shells/lib/common-plugins.nix;

  jetbrainsPlugins =
    inputs.nix-jetbrains-plugins.lib.pluginsForIdeWith
      {
        extraOverrides."dev.jetplugins.nix-pro" =
          origPlugin:
          origPlugin.overrideAttrs (old: {
            nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [
              pkgs.unzip
              pkgs.zip
              pkgs.xmlstarlet
            ];
            postInstall = (old.postInstall or "") + ''
              jar=$(find $out -name '*.jar' | grep -m1 "nix-pro")
              work=$(mktemp -d)
              (cd "$work" && unzip -q "$jar" META-INF/plugin.xml)
              xmlstarlet ed -d "//product-descriptor" "$work/META-INF/plugin.xml" > "$work/META-INF/plugin.xml.new"
              mv "$work/META-INF/plugin.xml.new" "$work/META-INF/plugin.xml"
              (cd "$work" && zip -q "$jar" META-INF/plugin.xml)
              rm -rf "$work"
            '';
          });
      }
      pkgs
      pkgs.jetbrains.idea
      (
        commonPlugins
        ++ [
          "com.github.copilot"
          "dev.jetplugins.nix-pro"
        ]
      );
in
{
  environment.systemPackages =
    with pkgs;
    [
      (jetbrains.plugins.addPlugins jetbrains.idea (lib.attrValues jetbrainsPlugins))
    ]
    ++ lib.concatMap (e: [
      (mkEnvScript e)
      (mkIdeScript e)
    ]) devEnvironments;
}
