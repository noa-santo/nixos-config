{ pkgs, ... }:
{
  networking.firewall.allowedTCPPorts = [ 8080 ];

  hardware.enableAllFirmware = true;
  services.fwupd.enable = true;

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

  users.defaultUserShell = pkgs.fish;

  system.stateVersion = "25.11";
}
