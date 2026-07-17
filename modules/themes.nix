{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    pkgs.bibata-cursors
    (pkgs.stdenvNoCC.mkDerivation {
      pname = "bibata-modern-pink";
      version = "1.0";
      src = ../assets/icons;

      installPhase = ''
        mkdir -p $out/share/icons
        cp -r Bibata-Modern-Pink $out/share/icons/
      '';
    })
  ];
}
