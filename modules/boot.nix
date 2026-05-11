{ pkgs, ... }:

{
  # ── Plymouth boot splash ────────────────────────────────────────────────────
  # Custom "simple" theme: dark background (Catppuccin base #1e1e2e) with a
  # mauve progress bar.  The two-step module shows the bar without needing any
  # image files in the resources directory.
  boot.plymouth = {
    enable = true;
    theme = "simple";
    themePackages = [
      (pkgs.stdenv.mkDerivation {
        name = "plymouth-simple-theme";
        src = ./plymouth/simple;
        installPhase = ''
          mkdir -p $out/share/plymouth/themes/simple/resources
          install -m 0644 simple.plymouth $out/share/plymouth/themes/simple/
          substituteInPlace $out/share/plymouth/themes/simple/simple.plymouth \
            --replace "@out@" "$out"
        '';
      })
    ];
  };

  # Suppress boot log spam so the Plymouth splash is actually visible
  boot.consoleLogLevel = 3;
  boot.kernelParams = [
    "quiet"
    "splash"
    "rd.systemd.show_status=auto"
    "rd.udev.log_level=3"
  ];

  # ── BBR TCP congestion control + network buffer tuning ─────────────────────
  boot.kernelModules = [ "tcp_bbr" ];
  boot.kernel.sysctl = {
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.core.default_qdisc"          = "fq";
    "net.core.wmem_max"               = 1073741824;
    "net.core.rmem_max"               = 1073741824;
    "net.ipv4.tcp_rmem"               = "4096 87380 1073741824";
    "net.ipv4.tcp_wmem"               = "4096 87380 1073741824";
  };
}
