{ kubenix, vars, flake, ... }:
let
  pvc = "transmission-downloads";
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
          config = { };
          downloads = {
            size = "200Gi";
            accessMode = "ReadWriteMany";
          };
        };
        values.addons.vpn = {
          enabled = true;
          env = {
            VPN_SERVICE_PROVIDER = "protonvpn";
            OPENVPN_USER = vars.secret "/vpn/user";
            OPENVPN_PASSWORD = vars.secret "/vpn/pass";
            SERVER_COUNTRIES = "United States";
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
          media.existingClaim = pvc;
        };
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
          media.existingClaim = pvc;
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
          media.existingClaim = pvc;
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
          media.existingClaim = pvc;
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
          media.existingClaim = pvc;
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
