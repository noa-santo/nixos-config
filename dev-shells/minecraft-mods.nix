{ pkgs, inputs, ... }:
let
  commonPlugins = import ./lib/common-plugins.nix;
in
{
  meta = {
    ide = "idea";
    icon = "idea";
    displayName = "InteliJ (Minecraft Mods Env)";
    comment = "Start InteliJ with Minecraft modding dev environment";
  };

  shell = pkgs.mkShell {
    packages = with inputs.nix-jetbrains-plugins.lib; [
      (buildIdeWithPlugins pkgs "idea" (
        commonPlugins
        ++ [
          "com.demonwav.minecraft-dev"
        ]
      ))
      pkgs.modrinth-app
      pkgs.mesa
      pkgs.glfw
    ];
    shellHook = ''
      echo "Minecraft Mod dev environment loaded."
    '';
  };
}
