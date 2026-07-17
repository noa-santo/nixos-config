{ pkgs, inputs, ... }:
let
  staticGc = pkgs.pkgsStatic.boehmgc;
in
pkgs.mkShell {
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc
    glibc
    zlib
    libGL
    wayland
    libxkbcommon
    libx11
    libxcursor
    libxi
    libxinerama
    libxrandr
  ];

  packages = with inputs.nix-jetbrains-plugins.lib; [
    pkgs.vlang
    pkgs.pkg-config

    pkgs.wayland
    pkgs.wayland-protocols
    pkgs.libxkbcommon
    pkgs.libGL
    pkgs.libx11
    pkgs.libxcursor
    pkgs.libxi
    pkgs.libxrandr

    (buildIdeWithPlugins pkgs "clion" [
       "IdeaVIM"
       "String Manipulation"
       "com.wakatime.intellij.plugin"
       "Key Promoter X"
       "com.fwdekker.randomness"
       "izhangzhihao.rainbow.brackets.lite"
       "io.vlang"
       "org.editorconfig.editorconfigjetbrains"
    ])
  ];
  shellHook = ''
    mkdir -p "$HOME/.cache/nix-toolchains/v-env"
    ln -sfn "${pkgs.vlang}/bin/v" "$HOME/.cache/nix-toolchains/v-env/v"
    ln -sfn "${pkgs.vlang}/lib" "$HOME/.cache/nix-toolchains/v-env/vlib"
    export LD_LIBRARY_PATH=/run/opengl-driver/lib:${pkgs.lib.makeLibraryPath [ pkgs.libGL pkgs.wayland pkgs.libxkbcommon ]}:$LD_LIBRARY_PATH
    export PKG_CONFIG_PATH=${pkgs.wayland}/lib/pkgconfig:${pkgs.libxkbcommon}/lib/pkgconfig:$PKG_CONFIG_PATH

    V_GC_DIR="./v/thirdparty/tcc/lib"
    if [ -d "$V_GC_DIR" ]; then
      if [ ! -L "$V_GC_DIR/libgc.a" ]; then
        echo "Found local V repository. Swapping out problematic libgc.a with Nix-native static GC..."
        mv "$V_GC_DIR/libgc.a" "$V_GC_DIR/libgc.a.bak" 2>/dev/null || true
        ln -s "${staticGc}/lib/libgc.a" "$V_GC_DIR/libgc.a"
      fi
    fi
    echo "V dev environment loaded."
  '';
}
