{
  pkgs,
  config,
  ...
}: let
  unstable = import <nixos-unstable> {config = {allowUnfree = true;};};
in {
  services.headscale = {
    enable = true;
    address = "127.0.0.1";
    port = 7070;
    settings = {
      logtail.enabled = false;
      server_url = "https://headscale.gladstone-life.com";
      dns_config.base_domain = "gladstone-life.com";
    };
  };
  services.nginx = {
    enable = true;
    virtualHosts = {
      "headscale" = {
        serverName = "headscale.gladstone-life.com";
        forceSSL = true;
        enableACME = true;
        # Headscale proxy
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.headscale.port}";
          proxyWebsockets = true;
        };
      };
    };
  };
}
