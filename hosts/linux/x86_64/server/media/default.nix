{ flake, pkgs, config, ... }:
let
  expose = svcs: flake.lib.recursiveMergeAttrs (map
    (service: {
      services.${service.name} = {
        enable = true;
        ${if (builtins.hasAttr "user" config.services.${service.name}) then "user" else null} = flake.lib.username;
      };
      services.nginx.virtualHosts."${service.domain}.${flake.lib.hostname}" = {
        useACMEHost = flake.lib.hostname;
        acmeRoot = null;
        forceSSL = true;
        locations."/".proxyPass = "http://127.0.0.1:${builtins.toString service.port}";
      };
    })
    svcs);
in
flake.lib.recursiveMergeAttrs [
  (expose [
    { name = "jellyfin"; domain = "player"; port = 8096; }
    { name = "jellyseerr"; domain = "requests"; port = config.services.jellyseerr.port; }
    { name = "transmission"; domain = "downloads"; port = config.services.transmission.settings.rpc-port; }
    { name = "sonarr"; domain = "shows"; port = 8989; }
    { name = "lidarr"; domain = "music"; port = 8686; }
    { name = "radarr"; domain = "movies"; port = 7878; }
    { name = "prowlarr"; domain = "indexer"; port = 9696; }
  ])
  {
    services = {
      transmission = {
        package = pkgs.transmission_4;
        webHome = pkgs.flood;
        # https://github.com/transmission/transmission/blob/main/docs/Editing-Configuration-Files.md
        settings = rec {
          download-dir = "/var/lib/media/downloads";
          incomplete-dir = "${download-dir}/incomplete";
          rpc-host-whitelist = "downloads.${flake.lib.hostname}";
          ratio-limit-enabled = true;
          ratio-limit = 5.0;
        };
      };
    };
  }
]
