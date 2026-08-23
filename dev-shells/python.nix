{ pkgs, inputs, ... }:
pkgs.mkShell {
  packages = with inputs.nix-jetbrains-plugins.lib; [
    pkgs.python3
    pkgs.python3Packages.pip
    pkgs.python3Packages.virtualenv
    pkgs.uv
    pkgs.mypy
    (buildIdeWithPlugins pkgs "pycharm" [
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
    export LD_LIBRARY_PATH="${
      pkgs.lib.makeLibraryPath [
        pkgs.stdenv.cc.cc.lib
        pkgs.zlib
        pkgs.glibc
      ]
    }:$LD_LIBRARY_PATH
    echo "Python dev environment loaded."
  '';
}
