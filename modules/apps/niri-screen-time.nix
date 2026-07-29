# tags: niri
{ pkgs, inputs, ... }: {
  environment.systemPackages = [
    inputs.niri-screen-time.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
