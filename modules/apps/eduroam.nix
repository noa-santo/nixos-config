# tags: eduroam
{ ... }:
{
  networking.networkmanager.enable = true;
  networking.networkmanager.ensureProfiles.environmentFiles = [ "/root/eduroam.env" ];
  networking.networkmanager.ensureProfiles.profiles = {
    eduroam = {
      connection = {
        id = "eduroam";
        type = "wifi";
      };
      wifi = {
        mode = "infrastructure";
        ssid = "eduroam";
      };
      wifi-security = {
        key-mgmt = "wpa-eap";
      };
      "802-1x" = {
        eap = "peap";
        identity = "$EDUROAM_USERNAME";
        password = "$EDUROAM_PASSWORD";
        phase2-auth = "mschapv2";
        ca-cert = "/etc/ssl/certs/eduroam_ca.pem";
        altsubject-matches = "DNS:radius.lrz.de";
      };
      ipv4 = {
        method = "auto";
      };
      ipv6 = {
        method = "auto";
      };
    };
  };
}
