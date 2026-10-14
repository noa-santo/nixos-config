# tags: ssh
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
      sha256 = "sha256:1zyh33673p60vwvyygcl0r2dqyd0irc8dsmbgwn470j6dsxj4lym";
    })
  ];
}
