{ pkgs, inputs, ... }:
{
  environment.systemPackages = with pkgs; [
    inputs.zen-browser.packages."${system}".default
    neovim
    kitty
    fastfetch
    kubectl
    grc
    pay-respects
    discord
    killall
    usbutils
  ];
}
