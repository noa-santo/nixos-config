# dont add stuff directly in here. only import
{ pkgs, ... }:
{
  imports = [
    ./fish.nix
    ./kitty.nix
    ./nvim/nvim.nix
  ];
}
