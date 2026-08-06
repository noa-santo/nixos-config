{ pkgs, inputs, ... }:
pkgs.mkShell {
  packages = with inputs.nix-jetbrains-plugins.lib; [
    pkgs.nodejs_24
    pkgs.fishPlugins.nvm
    pkgs.corepack

    pkgs.typescript
    pkgs.eslint
    pkgs.prettier
    pkgs.pnpm
    pkgs.typescript-language-server

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
