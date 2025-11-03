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
        locations."/".proxyPass =
          if service.name == "transmission"
          then "http://192.168.15.1:${builtins.toString service.port}"
          else "http://127.0.0.1:${builtins.toString service.port}";
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
    { name = "readarr"; domain = "books"; port = 8787; }
    { name = "prowlarr"; domain = "indexer"; port = 9696; }
  ])
  {
    age.secrets.torrent.rekeyFile = ./torrent.age;
    systemd.services = {
      jellyseerr.environment.LOG_LEVEL = "warning";
      transmission.vpnConfinement = {
        enable = true;
        vpnNamespace = "torrent";
      };
    };
    services = {
      transmission = {
        package = pkgs.transmission_4;
        webHome = pkgs.flood-for-transmission;
        # openPeerPorts = true;
        # https://github.com/transmission/transmission/blob/main/docs/Editing-Configuration-Files.md
        settings = rec {
          download-dir = "/var/lib/media/downloads";
          incomplete-dir = "${download-dir}/incomplete";
          rpc-host-whitelist = "downloads.${flake.lib.hostname}";
          idle-seeding-limit-enabled = true;
          # idle-seeding-limit = 30;
          ratio-limit-enabled = false; # Disabled to allow downloading without upload requirements
          # ratio-limit = 2.0;

          # Network configuration
          peer-port = (builtins.head config.vpnNamespaces.torrent.openVPNPorts).port;
          bind-address-ipv4 = "10.2.0.2"; # Bind to VPN IP for outbound connections
          encryption = 1; # Prefer encryption but allow unencrypted peers
          lpd-enabled = true; # Enable local peer discovery
          utp-enabled = true; # Enable uTP for better NAT traversal and lower latency

          # Performance tuning
          peer-limit-global = 240; # Increase global peer limit (default: 200)
          peer-limit-per-torrent = 60; # Increase per-torrent peer limit (default: 50)
          upload-slots-per-torrent = 14; # Optimize upload slots (default: varies)
          speed-limit-up-enabled = false; # Disable upload limit for better ratio
          queue-stalled-enabled = false; # Disabled to prevent auto-idling during initial peer discovery
          queue-stalled-minutes = 30; # Mark as stalled after 30min

          # Security
          rpc-bind-address = "192.168.15.1"; # Bind RPC/WebUI to VPN network namespace address
          blocklist-enabled = false; # Consider enabling with a good blocklist URL
          rpc-whitelist-enabled = false;
          # rpc-whitelist = [
          #   "192.168.15.5" # Access from default network namespace
          #   "192.168.86.*" # Access from other machines on specific subnet
          #   "127.0.0.1" # Access through loopback within VPN network namespace
          # ];
        };
      };
    };
    vpnNamespaces.torrent = {
      enable = true;
      wireguardConfigFile = config.age.secrets.torrent.path;
      accessibleFrom = [
        "192.168.86.0/24"
      ];
      portMappings = [
        { from = 9091; to = 9091; }
      ];
      openVPNPorts = [{
        port = 51820;
        protocol = "both";
      }];
    };
  }
]
