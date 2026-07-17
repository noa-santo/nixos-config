{ lib, hostTags ? [], ... }:

let
  allFiles = lib.filesystem.listFilesRecursive ./.;
  nixFiles = builtins.filter (f: 
    lib.hasSuffix ".nix" (builtins.toString f) && 
    builtins.baseNameOf f != "all.nix"
  ) allFiles;
  shouldImport = file:
    let
      content = builtins.readFile file;
      firstLine = builtins.head (lib.strings.splitString "\n" content);
    in
    if lib.strings.hasPrefix "# no-auto-import" firstLine then
      false
    else if lib.strings.hasPrefix "# tags:" firstLine then
      let
        rawTags = lib.strings.removePrefix "# tags:" firstLine;
        noSpaces = builtins.replaceStrings [" "] [""] rawTags;
        fileTags = lib.strings.splitString "," noSpaces;
      in
        # import if all tags match
        builtins.all (t: builtins.elem t hostTags) fileTags
    else
      # import if no tags
      true;

in
{
  imports = builtins.filter shouldImport nixFiles;
}