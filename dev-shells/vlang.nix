{ pkgs, inputs, ... }:
pkgs.mkShell {
  packages = with inputs.nix-jetbrains-plugins.lib; [
    pkgs.vlang
    (buildIdeWithPlugins pkgs "clion" [
       "IdeaVIM"
       "String Manipulation"
       "com.wakatime.intellij.plugin"
       "Key Promoter X"
       "com.fwdekker.randomness"
       "izhangzhihao.rainbow.brackets.lite"
       "io.vlang"
    ])
  ];
  shellHook = ''
    echo "V dev environment loaded."
  '';
}
