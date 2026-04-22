{ pkgs, inputs, ... }:
{
  environment.systemPackages = with pkgs; [
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
