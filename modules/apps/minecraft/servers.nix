{ pkgs, lib, inputs, ... }:

{

  imports = [
    ./meow.nix
    ./create.nix
  ];

  environment.systemPackages = with pkgs; [
   tmux
    (pkgs.writeShellScriptBin "mc-attach" ''
       exec sudo tmux -S /run/minecraft/"$1".sock attach
     '')
   ];

  networking.firewall.allowedUDPPorts = [ 19132 ];

  services.minecraft-servers = {
    enable = true;
    eula = true;
    openFirewall = true;
  };

  users.users.minecraft = {
    isSystemUser = true;
    home = "/srv/minecraft";
    shell = pkgs.bash;
  };
}