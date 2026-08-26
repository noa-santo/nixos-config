{ inputs, pkgs, ... }:
{
  environment.systemPackages = [
    inputs.nix-search.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
