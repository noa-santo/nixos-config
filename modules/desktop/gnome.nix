# tags: gnome
{
  pkgs,
  ...
}:
{
  imports = [ ./gdm.nix ];

  services = {
    desktopManager.gnome.enable = true;
    gnome.gnome-keyring.enable = true;
  };

  environment.systemPackages = with pkgs; [
    gnome-tweaks
  ];

  environment.gnome.excludePackages = [
    pkgs.epiphany
  ];

  programs.dconf.enable = true;
}
