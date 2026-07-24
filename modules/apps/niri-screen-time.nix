# tags: niri
{ pkgs, inputs, ... }: {
  environment.systemPackages = [
    inputs.niri-screen-time.packages.${pkgs.system}.default
  ];
}
