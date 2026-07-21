{ pkgs, ... }:
pkgs.mkShell {
  packages = [
    pkgs.nodejs_24
    pkgs.fishPlugins.nvm
    pkgs.corepack

    pkgs.nodePackages_latest.typescript
    pkgs.nodePackages_latest.ts-node
    pkgs.nodePackages_latest.eslint
    pkgs.nodePackages_latest.prettier
    pkgs.nodePackages_latest.pnpm
    pkgs.nodePackages_latest.typescript-language-server

    (pkgs.jetbrains.plugins.addPlugins pkgs.jetbrains.webstorm [
      pkgs.jetbrains.plugins.github-copilot-fixed
      "ideavim"
      "wakatime"
      "gittoolbox"
      "key-promoter-x"
      "randomness"
      "csv-editor"
      "rainbow-brackets"
      "developer-tools"
      "-env-files"

      (pkgs.fetchurl {
        # "jetbrains-ai-assistant"
        url = "https://plugins.jetbrains.com/files/26104/789538/ej-release-251.167.97.zip";
        sha256 = "sha256-5lGS0V1YzGjGajk7VvUWqfgIZGr3jc0+WIOyo/LRrHk=";
      })
      (pkgs.fetchurl {
        # "-ignore"
        url = "https://plugins.jetbrains.com/files/7495/678216/ignore-4.5.6.zip";
        sha256 = "sha256-jbRIeXslsyC7YcH3v8g2kFQgGFy2TzX1jviQjt9y4b0=";
      })
      (pkgs.fetchurl {
        # "foldable-project-view"
        url = "https://plugins.jetbrains.com/files/17288/638325/Foldable_Project_View-2.0.0.zip";
        sha256 = "sha256-zBFqPUXPZSI/dvxlY2mbQcn0CXLraBlgbb4qlMq/pOQ=";
      })
      (pkgs.fetchurl {
        # "grazie-pro"
        url = "https://plugins.jetbrains.com/files/16136/813770/grazie-pro-0.3.388-251.zip";
        sha256 = "sha256-ZnLRYx1abi5DaWJIXU8ksplLGaTfTQiAXAWLO3YFeLM=";
      })

      # "jetbrains-junie"
      # "jetbrains-ai-assistant"
    ])
  ];
  shellHook = ''
    echo "Typescript dev environment loaded."

    if command -v corepack >/dev/null 2>&1; then
      corepack enable >/dev/null 2>&1 || true
    fi
  '';
}
