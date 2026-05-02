{ pkgs, inputs, ... }:
pkgs.mkShell {
  packages = with inputs.nix-jetbrains-plugins.lib; [
    (buildIdeWithPlugins pkgs "idea"  [
        "IdeaVIM"
        "String Manipulation"
        "com.wakatime.intellij.plugin"
        "Key Promoter X"
        "com.fwdekker.randomness"
        "izhangzhihao.rainbow.brackets.lite"
        "com.demonwav.minecraft-dev"
    ])
  ];
  shellHook = ''
    echo "Minecraft Mod dev environment loaded."
  '';
}
