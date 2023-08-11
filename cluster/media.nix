{ kubenix, vars, flake, ... }:
let
  # /data             # appear as one fs (e.g., hardlinking)
  # └── ${type}       # volume mount points
  #    ├── .downloads # downloaded files from torrent
  #    └── ...        # imported files ready for consumption

  # torrent and player need access to everything
  data = {
    shows = {
      existingClaim = "sonarr-data";
      mountPath = "/data/shows";
    };
    movies = {
      existingClaim = "radarr-data";
      mountPath = "/data/movies";
    };
    music = {
      existingClaim = "lidarr-data";
      mountPath = "/data/music";
    };
    books = {
      existingClaim = "readarr-data";
      mountPath = "/data/books";
    };
  };
in
{
  submodules.instances = {

    transmission = {
      submodule = "release";
      args = {
        image = "linuxserver/transmission:4.0.3";
        host = "downloads";
        port = 9091;
        persistence = {
          config.enabled = true;
        } // data;
        values = {
          persistence.settings = {
            enabled = true;
            type = "configMap";
            name = "transmission-settings";
            mountPath = "/config/settings.json";
            subPath = "settings.json";
            readOnly = true;
          };
          configMaps.settings = {
            enabled = true;
            data."settings.json" = builtins.toJSON {
              download-dir = "/data";
              download-queue-size = 10;
              # idle-seeding-limit = 30; # minutes
              idle-seeding-limit-enabled = true;
              # ratio-limit = 2;
              # ratio-limit-enabled = false;
              rpc-host-whitelist-enabled = false;
              rpc-whitelist-enabled = false;
              # seed-queue-enabled = false;
              # trash-original-torrent-files = false;
            };
          };
          addons.vpn = {
            enabled = true;
            env = {
              VPN_SERVICE_PROVIDER = "protonvpn";
              OPENVPN_USER = vars.secret "/vpn/user";
              OPENVPN_PASSWORD = vars.secret "/vpn/pass";
              SERVER_CITIES = "Washington DC,New York City";
            };
          };
        };
      };
    };

    jellyfin = {
      submodule = "release";
      args = {
        image = "jellyfin/jellyfin:10.8.10";
        host = "player";
        port = 8096;
        persistence = {
          config.enabled = true;
        } // data;
      };
    };

    sonarr = {
      submodule = "release";
      args = {
        image = "linuxserver/sonarr:3.0.10";
        host = "shows";
        port = 8989;
        persistence = {
          config.enabled = true;
          data = {
            enabled = true;
            size = "100Gi";
            accessMode = "ReadWriteMany";
            mountPath = "/data/shows";
          };
        };
      };
    };

    radarr = {
      submodule = "release";
      args = {
        image = "linuxserver/radarr:4.6.4";
        host = "movies";
        port = 7878;
        persistence = {
          config.enabled = true;
          data = {
            enabled = true;
            size = "100Gi";
            accessMode = "ReadWriteMany";
            mountPath = "/data/movies";
          };
        };
      };
    };

    lidarr = {
      submodule = "release";
      args = {
        image = "linuxserver/lidarr:1.2.6";
        host = "music";
        port = 8686;
        persistence = {
          config.enabled = true;
          data = {
            enabled = true;
            size = "100Gi";
            accessMode = "ReadWriteMany";
            mountPath = "/data/music";
          };
        };
      };
    };

    readarr = {
      submodule = "release";
      args = {
        image = "linuxserver/readarr:develop";
        host = "books";
        port = 8787;
        persistence = {
          config.enabled = true;
          data = {
            enabled = true;
            size = "10Gi";
            accessMode = "ReadWriteMany";
            mountPath = "/data/books";
          };
        };
      };
    };

    prowlarr = {
      submodule = "release";
      args = {
        image = "linuxserver/prowlarr:1.6.3";
        host = "indexer";
        port = 9696;
        persistence.config.enabled = true;
      };
    };

  };
}
