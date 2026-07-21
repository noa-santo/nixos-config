{ config, pkgs, ... }:
{
  home.pointerCursor.enable = true;
  home.pointerCursor = {
    name = "Bibata-Modern-Pink";
    package = (
      pkgs.stdenvNoCC.mkDerivation {
        pname = "bibata-modern-pink";
        version = "1.0";
        src = ../../assets/icons;

        installPhase = ''
          mkdir -p $out/share/icons
          cp -r Bibata-Modern-Pink $out/share/icons/
        '';
      }
    );
    size = 24;
    x11 = {
      enable = true;
      defaultCursor = "Bibata-Modern-Pink";
    };
    sway.enable = true;
  };
}
