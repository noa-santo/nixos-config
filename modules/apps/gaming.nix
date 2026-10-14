# tags: gaming
{
  pkgs,
  hostTags ? [ ],
  ...
}:
let
  isServer = builtins.elem "server" hostTags;
in
{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = isServer;
    localNetworkGameTransfers.openFirewall = true;
    gamescopeSession.enable = true;
  };
  
  environment.systemPackages = with pkgs; [
    moonlight-qt
  ];
  hardware = {
    steam-hardware.enable = true;
    graphics.enable = true;
  };
}
