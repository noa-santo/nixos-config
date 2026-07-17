# no-auto-import
{pkgs, ... }:
{
  hanabi = pkgs.stdenv.mkDerivation rec {
    pname = "gnome-ext-hanabi";
    version = "";
    dontBuild = false;
    nativeBuildInputs = with pkgs; [
      meson
      ninja
      glib
      nodejs
      wrapGAppsHook4
      appstream-glib
      gobject-introspection
      shared-mime-info
    ];

    buildInputs = with pkgs; [
      gst_all_1.gstreamer
      gst_all_1.gst-plugins-base
      gst_all_1.gst-plugins-good
      gst_all_1.gst-plugins-bad
      gst_all_1.gst-plugins-ugly
      gst_all_1.gst-libav
      gst_all_1.gst-vaapi
      clapper
      gjs
      gtk4
      wayland
      wayland-protocols
    ];
    dontWrapGApps = true;

    postPatch = ''
      patchShebangs build-aux/meson-postinstall.sh
    '';

    postFixup = ''
      wrapGApp "$out/share/gnome-shell/extensions/hanabi-extension@jeffshee.github.io/renderer/renderer.js"
      ln -s "$out/share/gsettings-schemas/gnome-ext-hanabi-/glib-2.0/schemas" "$out/share/gnome-shell/extensions/hanabi-extension@jeffshee.github.io/schemas"
    '';

    src = pkgs.fetchFromGitHub {
      owner = "jeffshee";
      repo = "gnome-ext-hanabi";
      rev = "4bd29ce7e5d339d9f933d4f22e94aaf83404fd5f";
      sha256 = "sha256-O3fly4THSpod9PoyPQO2DyXa3FUImh3k4DhQW85MqhM=";
    };
  };
}