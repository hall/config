{ kubenix, vars, flake, ... }:
flake.lib.recursiveMerge [
  (vars.simple {
    inherit kubenix;
    image = "photoprism/photoprism:221116-jammy";
    port = 2342;
    host = "photos";
    persistence = {
      # unmodified images
      originals.size = "30Gi";
      # db, cache, session, thumbnails, etc
      storage.size = "10Gi";
    };
    values.env = {
      # PHOTOPRISM_AUTH_MODE = "public"; # disable auth
      PHOTOPRISM_SPONSOR = "true";
      PHOTOPRISM_STORAGE_PATH = "/storage";
      PHOTOPRISM_ORIGINALS_PATH = "/originals";
      PHOTOPRISM_DATABASE_DRIVER = "mysql";
      PHOTOPRISM_DATABASE_SERVER = "mariadb:3306";
      PHOTOPRISM_DATABASE_PASSWORD = vars.secret "/mariadb/photoprism";
    };
  })

  {
    helm.releases.mariadb = {
      chart = kubenix.lib.helm.fetch {
        repo = "https://groundhog2k.github.io/helm-charts/";
        chart = "mariadb";
        version = "0.6.4";
        sha256 = "sha256-AF1oIYnzsO/Ool48cmjYGgZJE+dx1g2qFEia0WhyKiw=";
      };
      values = {
        userDatabase = {
          name = "photoprism";
          user = "photoprism";
          password = vars.secret "/mariadb/photoprism";
        };
        settings.rootPassword = vars.secret "/mariadb/root";
        storage = {
          className = "longhorn-static";
          requestedSize = "8Gi";
        };
      };
    };
  }
]
