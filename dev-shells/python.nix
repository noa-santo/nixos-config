{ pkgs, inputs, ... }:
pkgs.mkShell {
  packages = with inputs.nix-jetbrains-plugins.lib; [
    pkgs.python3
    pkgs.python3Packages.pip
    pkgs.python3Packages.virtualenv
    pkgs.uv
    pkgs.mypy
    (buildIdeWithPlugins pkgs "pycharm"  [
        "IdeaVIM"
        "String Manipulation"
        "com.wakatime.intellij.plugin"
        "Key Promoter X"
        "com.fwdekker.randomness"
        "izhangzhihao.rainbow.brackets.lite"
        "works.szabope.mypy"
        "com.koxudaxi.pydantic"
    ])
  ];
  shellHook = ''
    echo "Python dev environment loaded."
  '';
}
