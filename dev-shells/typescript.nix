{ pkgs, inputs, ... }:
let
  commonPlugins = import ./lib/common-plugins.nix;
in
{
  meta = {
    ide = "webstorm";
    icon = "typescript";
    displayName = "Webstorm (Typescript Env)";
    comment = "Start Webstorm with Typescript dev environment";
  };

  shell = pkgs.mkShell {
    packages = with inputs.nix-jetbrains-plugins.lib; [
      pkgs.nodejs_24
      pkgs.fishPlugins.nvm
      pkgs.corepack

      pkgs.typescript
      pkgs.eslint
      pkgs.prettier
      pkgs.pnpm
      pkgs.typescript-language-server

      (buildIdeWithPlugins pkgs "webstorm" commonPlugins)
    ];
    shellHook = ''
      echo "Typescript dev environment loaded."

      if command -v corepack >/dev/null 2>&1; then
        corepack enable >/dev/null 2>&1 || true
      fi
    '';
  };
}
