{ pkgs, ... }:
{
  zramSwap.enable = true;
  system.stateVersion = "26.05";
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      zlib
      zstd
      stdenv.cc.cc
      curl
      openssl
      attr
      libssh
      bzip2
      libxml2
      acl
      libsodium
      util-linux
      xz
      systemd
    ];
  };

  services.gvfs.enable = true;
  services.udev.packages = [ pkgs.libmtp ];
  environment.systemPackages = with pkgs; [
    elan
    gcc
    gmp
    zlib
    sg3_utils
  ];
}
