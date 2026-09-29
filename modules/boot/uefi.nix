# tags: uefi
#
# Standard UEFI systemd-boot setup. Was duplicated identically on dell
# and lenowo-thiccpad; gated on its own "uefi" tag rather than "laptop"
# since boot method and form factor are separate concerns.
_: {
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
}
