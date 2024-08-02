{ flake, pkgs, ... }: {

  # nixarr = {
  #   enable = true;
  #   transmission = {
  #     enable = true;
  #     extraSettings = { };
  #   };
  # };

  services = {
    jellyfin = {
      enable = true;
      user = flake.lib.username;
      # group = "syncthing";
      # openFirewall = true;
    };
    nginx.virtualHosts = {
      "player.${flake.lib.hostname}" = {
        useACMEHost = flake.lib.hostname;
        acmeRoot = null;
        forceSSL = true;
        locations."/".proxyPass = "http://127.0.0.1:8096";
      };
    };

      # enable = true;
    transmission = {
      package = pkgs.transmission_4;
      user = flake.lib.username;
      # group = "syncthing";
      # openFirewall = true;
      webHome = pkgs.flood-for-transmission;
      settings = {
        # download-dir = "/var/lib/media/downloads";

      };
    };
    nginx.virtualHosts = {
      "downloads.${flake.lib.hostname}" = {
        useACMEHost = flake.lib.hostname;
        acmeRoot = null;
        forceSSL = true;
        locations."/".proxyPass = "http://127.0.0.1:9091";
      };
    };

    sonarr = {
      enable = true;
      user = flake.lib.username;
      # group = "syncthing";
      # openFirewall = true;
    };
    nginx.virtualHosts = {
      "shows.${flake.lib.hostname}" = {
        useACMEHost = flake.lib.hostname;
        acmeRoot = null;
        forceSSL = true;
        locations."/".proxyPass = "http://127.0.0.1:8989";
        # proxy_http_version 1.1;
        # proxy_set_header Upgrade $http_upgrade;
        # proxy_set_header Connection $http_connection;
      };
    };

    radarr = {
      enable = true;
      user = flake.lib.username;
      # group = "syncthing";
      # openFirewall = true;
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
      # group = "syncthing";
      # openFirewall = true;
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
      # group = "syncthing";
      # openFirewall = true;
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
  environment.systemPackages = [
    pkgs.jellyfin
    pkgs.jellyfin-web
    pkgs.jellyfin-ffmpeg
  ];
}
