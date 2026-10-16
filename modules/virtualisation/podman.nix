# tags: podman
{...}:
{
  virtualisation.podman = {
    enable = true;
    dockerCompat = true; 
    defaultNetwork.settings.dns_enabled = true; 
  };
  virtualisation.containers.containersConf.settings.engine.search_registries = [ "docker.io" ];
}
