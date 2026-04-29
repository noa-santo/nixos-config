final: prev:

let
  goodixSrc = prev.fetchFromGitHub {
    owner  = "AndyHazz";
    repo   = "goodix53x5-libfprint";
    rev    = "main";
    hash   = "sha256-wJV4dz2DxpfPUIHPjHcgv8tE3pLHBdhjFOd1E7F3LT4=";
  };

in {
  libfprint-goodix53x5 = prev.libfprint.overrideAttrs (old: {
    pname = "libfprint-goodix53x5";
    doCheck = false;

    nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ prev.pkg-config ];
    buildInputs = (old.buildInputs or []) ++ [ prev.opencv4 prev.openssl prev.glib ];

    prePatch = (old.prePatch or "") + ''
      cp -r --no-preserve=mode ${goodixSrc}/drivers/goodix53x5 libfprint/drivers/goodix53x5
      cp -r --no-preserve=mode ${goodixSrc}/sigfm libfprint/sigfm
    '';

    patches = (old.patches or []) ++ [ "${goodixSrc}/meson-integration.patch" ];

    postPatch = (old.postPatch or "") + ''
      substituteInPlace libfprint/meson.build \
        --replace-warn "include_directories('/usr/include/opencv4')" \
                  "include_directories('${prev.opencv4}/include/opencv4')"

      substituteInPlace meson.build \
        --replace-warn "subdir('tests')" "" \
        --replace-warn "subdir('examples')" ""

      echo "==> Patching Goodix driver for stability..."
      if [ -f libfprint/drivers/goodix53x5/goodix.c ]; then
        # 1. Bypass TLS verification
        sed -i '/g_tls_client_connection_new/a \    if (self->tls_connection) g_tls_client_connection_set_validation_flags(G_TLS_CLIENT_CONNECTION(self->tls_connection), 0);' libfprint/drivers/goodix53x5/goodix.c

        # 2. Extreme USB Timeouts (15 seconds)
        # Replaces common timeout values (2000, 3000, 5000) with 15000
        sed -i 's/\([,_ ]\)2000\([,)]\)/\115000\2/g' libfprint/drivers/goodix53x5/*.c
        sed -i 's/\([,_ ]\)3000\([,)]\)/\115000\2/g' libfprint/drivers/goodix53x5/*.c
        sed -i 's/\([,_ ]\)5000\([,)]\)/\115000\2/g' libfprint/drivers/goodix53x5/*.c

        # 3. Increase GTask timeouts if they exist
        sed -i 's/g_task_set_return_on_cancel/ \/\/ g_task_set_return_on_cancel/g' libfprint/drivers/goodix53x5/goodix.c
      fi
    '';

    postInstall = (old.postInstall or "") + ''
      install -Dm644 ${goodixSrc}/91-goodix-fingerprint.rules \
        $out/lib/udev/rules.d/91-goodix-fingerprint.rules
    '';

    meta = old.meta // {
      description  = "libfprint with Goodix HTK32 (27c6:5385/5395) driver";
      homepage     = "https://github.com/AndyHazz/goodix53x5-libfprint";
      license      = prev.lib.licenses.lgpl21Plus;
    };
  });
}
