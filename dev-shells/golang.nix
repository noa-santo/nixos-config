{ pkgs, inputs, ... }:
pkgs.mkShell {
  packages = with inputs.nix-jetbrains-plugins.lib; [
    (buildIdeWithPlugins pkgs "goland"  [
            "IdeaVIM"
            "String Manipulation"
            "com.wakatime.intellij.plugin"
            "Key Promoter X"
            "com.fwdekker.randomness"
            "izhangzhihao.rainbow.brackets.lite"
            "com.github.copilot"
    ])
    pkgs.go
    pkgs.direnv
  ];
  shellHook = ''
    echo "Go dev environment loaded."
  '';
}