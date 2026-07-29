{ pkgs, ... }:
pkgs.mkShell {
  packages = with inputs.nix-jetbrains-plugins.lib; [
    pkgs.nodejs_24
    pkgs.fishPlugins.nvm
    pkgs.corepack

    pkgs.nodePackages_latest.typescript
    pkgs.nodePackages_latest.ts-node
    pkgs.nodePackages_latest.eslint
    pkgs.nodePackages_latest.prettier
    pkgs.nodePackages_latest.pnpm
    pkgs.nodePackages_latest.typescript-language-server

     (buildIdeWithPlugins pkgs "webstorm" [
          "IdeaVIM"
          "String Manipulation"
          "com.wakatime.intellij.plugin"
          "Key Promoter X"
          "com.fwdekker.randomness"
          "izhangzhihao.rainbow.brackets.lite"
        ])
  ];
  shellHook = ''
    echo "Typescript dev environment loaded."

    if command -v corepack >/dev/null 2>&1; then
      corepack enable >/dev/null 2>&1 || true
    fi
  '';
}
