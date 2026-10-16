{ pkgs, ... }:
{
  sops = {
    defaultSopsFile = ../../secrets/common.yaml;
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    age.generateKey = true;
  };

  environment.sessionVariables = {
    SOPS_AGE_KEY_FILE = "/run/secrets/sops/age/keys.txt";
  };

  environment.systemPackages = with pkgs; [
    sops
    ssh-to-age
  ];
}
