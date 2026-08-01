_: {
  services.printing.enable = true;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
}
