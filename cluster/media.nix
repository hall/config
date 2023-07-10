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
        image = "linuxserver/transmission:version-3.00-r6";
        host = "downloads";
        port = 9091;
        persistence = {
          config.enabled = true;
        } // data;
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

    ombi = {
      submodule = "release";
      args = {
        image = "linuxserver/ombi:4.39.1";
        host = "requests";
        port = 3579;
        persistence.config.enabled = true;
      };
    };

    sonarr = {
      submodule = "release";
      args = {
        image = "linuxserver/sonarr:3.0.9";
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
        image = "linuxserver/radarr:4.3.2";
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
        image = "linuxserver/lidarr:1.0.2";
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
        image = "linuxserver/prowlarr:1.5.2";
        host = "indexer";
        port = 9696;
        persistence.config.enabled = true;
      };
    };

  };
}
