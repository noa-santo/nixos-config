# dont add packages directly in here. only import
{ pkgs, inputs, system, ... }:
{
  imports = [
    ./general.nix
    ./dev.nix
    ./themes.nix
    ./minecraft.nix
  ];
}
