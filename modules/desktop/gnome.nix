# tags: gnome
{
  pkgs,
  ...
}:
{
  services = {
    displayManager.gdm.enable = true;
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
