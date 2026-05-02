{ pkgs, ... }:
pkgs.mkShell {
  packages = [
    pkgs.python3
    pkgs.python3Packages.pip
    pkgs.python3Packages.virtualenv
    pkgs.uv
    pkgs.mypy
    (pkgs.jetbrains.plugins.addPlugins pkgs.jetbrains.pycharm [
        pkgs.jetbrains.plugins.github-copilot-fixed
        "ideavim"
        "string-manipulation"
        "wakatime"
        "gittoolbox"
        "key-promoter-x"
        "randomness"
        "csv-editor"
        "rainbow-brackets"
        "developer-tools"
        "-env-files"

        (pkgs.fetchurl { # "jetbrains-ai-assistant"
          url = "https://plugins.jetbrains.com/files/26104/789538/ej-release-251.167.97.zip";
          sha256 = "sha256-5lGS0V1YzGjGajk7VvUWqfgIZGr3jc0+WIOyo/LRrHk=";
        })
        (pkgs.fetchurl { # "-ignore"
          url = "https://plugins.jetbrains.com/files/7495/678216/ignore-4.5.6.zip";
          sha256 = "sha256-jbRIeXslsyC7YcH3v8g2kFQgGFy2TzX1jviQjt9y4b0=";
        })
        (pkgs.fetchurl { # "foldable-project-view"
          url = "https://plugins.jetbrains.com/files/17288/638325/Foldable_Project_View-2.0.0.zip";
          sha256 = "sha256-zBFqPUXPZSI/dvxlY2mbQcn0CXLraBlgbb4qlMq/pOQ=";
        })
        (pkgs.fetchurl { # "mypy"
          url = "https://plugins.jetbrains.com/files/25888/737968/Mypy_PyCharm_Plugin-1.0.19-signed.zip";
          sha256 = "sha256-0f22S8PboGmk7mJIkeh4XEypDuG96fzMd0v30Wh358I=";
        })
        (pkgs.fetchurl { # "pydantic"
          url = "https://plugins.jetbrains.com/files/12861/733842/pydantic-pycharm-plugin-0.4.18-signed.zip";
          sha256 = "sha256-1EE5O3rQ3jOTbO6IRpnu+yL/pYK0plUChtmvTMnuec4=";
        })
        (pkgs.fetchurl { # "grazie-pro"
          url = "https://plugins.jetbrains.com/files/16136/813770/grazie-pro-0.3.388-251.zip";
          sha256 = "sha256-ZnLRYx1abi5DaWJIXU8ksplLGaTfTQiAXAWLO3YFeLM=";
        })

        # "jetbrains-junie"
        # "jetbrains-ai-assistant"
    ])
  ];
  shellHook = ''
    echo "Python dev environment loaded."
  '';
}
