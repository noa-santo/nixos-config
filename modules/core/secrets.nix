{ pkgs, ... }:
{
  sops = {
    defaultSopsFile = ../../secrets/common.yaml;
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    age.generateKey = true;
    age.keyFile = "/root/.config/sops/age/keys.txt";
  };

  environment.sessionVariables = {
    SOPS_AGE_KEY_FILE = "/root/.config/sops/age/keys.txt";
    SOPS_AGE_KEY_CMD = "ssh-to-age -private-key -i /etc/ssh/ssh_host_ed25519_key";
  };

  environment.systemPackages = with pkgs; [
    sops
    ssh-to-age
  ];
}
