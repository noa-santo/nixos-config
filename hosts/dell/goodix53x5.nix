{ pkgs }:

pkgs.stdenv.mkDerivation rec {
  pname = "libfprint-2-tod1-goodix53x5";
  version = "0.1.0";

  src = pkgs.fetchFromGitHub {
    owner = "AndyHazz";
    repo = "goodix53x5-libfprint";
    rev = "main";
    sha256 = "sha256-wJV4dz2DxpfPUIHPjHcgv8tE3pLHBdhjFOd1E7F3LT4="; 
  };

  dontBuild = true;
  dontConfigure = true;

  nativeBuildInputs = [ pkgs.autoPatchelfHook ];

  buildInputs = with pkgs; [
    libfprint-tod
    glib
    pixman
    libusb1
  ];

  passthru.driverPath = "/lib/libfprint-2/tod-1";

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/libfprint-2/tod-1/
    cp libfprint-2-tod1-goodix53x5.so $out/lib/libfprint-2/tod-1/
    runHook postInstall
  '';
}
