# ssh
{ config, ... }:
{
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  users.users.${config.mainUser}.openssh.authorizedKeys.keyFiles = [
    (builtins.fetchurl {
      url = "https://sshid.io/owoc";
      sha256 = "sha256-Kdxqd+xey71i6p7VdfMxS9FFG5xmGkaie0ltoMW/K/I=";
    })
  ];
}
