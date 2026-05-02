{ pkgs, ... }:
pkgs.mkShell {
  packages = [
    (pkgs.jetbrains.plugins.addPlugins pkgs.jetbrains.idea [
        "ideavim"
        "string-manipulation"
        "wakatime"
        "gittoolbox"
        "key-promoter-x"
        "randomness"
        "csv-editor"
        "rainbow-brackets"
        "-env-files"
        "com.demonwav.minecraft-dev"
        "com.intellij.grazie.pro"
    ])
  ];
  shellHook = ''
    echo "Minecraft Mod dev environment loaded."
  '';
}
