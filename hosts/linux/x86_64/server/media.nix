{ flake, pkgs, config, ... }: {
  services = {
    jellyfin = {
      enable = true;
      user = flake.lib.username;
    };
    nginx.virtualHosts = {
      "player.${flake.lib.hostname}" = {
        useACMEHost = flake.lib.hostname;
        acmeRoot = null;
        forceSSL = true;
        locations."/".proxyPass = "http://127.0.0.1:8096";
      };
    };

    jellyseerr.enable = true;
    nginx.virtualHosts = {
      "requests.${flake.lib.hostname}" = {
        useACMEHost = flake.lib.hostname;
        acmeRoot = null;
        forceSSL = true;
        locations."/".proxyPass = "http://127.0.0.1:${toString config.services.jellyseerr.port}";
      };
    };

    transmission = {
      enable = true;
      package = pkgs.transmission_4;
      user = flake.lib.username;
      webHome = pkgs.flood-for-transmission;
      settings = {
        download-dir = "/var/lib/media/downloads";
      };
    };
    nginx.virtualHosts = {
      "downloads.${flake.lib.hostname}" = {
        useACMEHost = flake.lib.hostname;
        acmeRoot = null;
        forceSSL = true;
        locations."/".proxyPass = "http://127.0.0.1:${toString config.services.transmission.settings.rpc-port}";
      };
    };

    sonarr = {
      enable = true;
      user = flake.lib.username;
    };
    nginx.virtualHosts = {
      "shows.${flake.lib.hostname}" = {
        useACMEHost = flake.lib.hostname;
        acmeRoot = null;
        forceSSL = true;
        locations."/".proxyPass = "http://127.0.0.1:8989";
      };
    };

    radarr = {
      enable = true;
      user = flake.lib.username;
    };
    nginx.virtualHosts = {
      "movies.${flake.lib.hostname}" = {
        useACMEHost = flake.lib.hostname;
        acmeRoot = null;
        forceSSL = true;
        locations."/".proxyPass = "http://127.0.0.1:7878";
      };
    };

    lidarr = {
      enable = true;
      user = flake.lib.username;
    };
    nginx.virtualHosts = {
      "music.${flake.lib.hostname}" = {
        useACMEHost = flake.lib.hostname;
        acmeRoot = null;
        forceSSL = true;
        locations."/".proxyPass = "http://127.0.0.1:8686";
      };
    };

    prowlarr = {
      enable = true;
      # user = flake.lib.username;
    };
    nginx.virtualHosts = {
      "indexer.${flake.lib.hostname}" = {
        useACMEHost = flake.lib.hostname;
        acmeRoot = null;
        forceSSL = true;
        locations."/".proxyPass = "http://127.0.0.1:9696";
      };
    };
  };
}
