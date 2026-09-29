{
  pkgs,
  inputs,
  lib,
  devShellsDir,
}:
let
  files = builtins.filter (f: lib.hasSuffix ".nix" f) (
    builtins.attrNames (builtins.readDir devShellsDir)
  );

  toEntry =
    file:
    let
      name = lib.removeSuffix ".nix" file;
      entry = import (devShellsDir + "/${file}") { inherit pkgs inputs; };
      meta = entry.meta or null;
    in
    if meta == null then
      null
    else
      {
        inherit name;
        # binName lets a shell's flake attr name (used with `nix develop
        # .#<name>`) differ from the CLI wrapper prefix, e.g. the
        # "golang" shell exposes "go-env"/"go-ide".
        binName = meta.binName or name;
        ide = meta.ide;
        icon = meta.icon or meta.ide;
        displayName = meta.displayName or meta.ide;
        comment = meta.comment or "Start ${meta.displayName or meta.ide}";
      };
in
builtins.filter (e: e != null) (map toEntry files)
