# tags: gaming
{
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
}
