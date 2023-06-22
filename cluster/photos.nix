{ kubenix, vars, ... }: {
  submodules.instances.photoprism = {
    submodule = "release";
    args = {
      image = "photoprism/photoprism:230615";
      port = 2342;
      host = "photos";
      persistence = {
        # unmodified images
        originals = {
          size = "100Gi";
          # mountPath = 
        };
        # db, cache, session, thumbnails, etc
        storage = {
          size = "30Gi";
          # mountPath = "/storage";
        };
        import = {
          accessMode = "ReadWriteMany";
          # mountPath = "/import";
          size = "5Gi";
        };
      };
      values = {
        ingress.main.annotations = {
          "traefik.ingress.kubernetes.io/router.middlewares" = "kube-system-home@kubernetescrd";
        };
        env = {
          # PHOTOPRISM_AUTH_MODE = "public"; # disable auth
          PHOTOPRISM_SPONSOR = "true";
          PHOTOPRISM_STORAGE_PATH = "/storage";
          PHOTOPRISM_ORIGINALS_PATH = "/originals";
          PHOTOPRISM_IMPORT_PATH = "/import";
          PHOTOPRISM_DATABASE_DRIVER = "mysql";
          PHOTOPRISM_DATABASE_SERVER = "mariadb:3306";
          PHOTOPRISM_DATABASE_PASSWORD = vars.secret "/mariadb/photoprism";
        };
      };
    };
  };

  kubernetes = {
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
    # TODO: upstream chart b64 encodes these before we get a chance to replace them
    resources.secrets.mariadb.stringData = {
      MARIADB_ROOT_PASSWORD = vars.secret "/mariadb/root";
      MARIADB_PASSWORD = vars.secret "/mariadb/photoprism";
    };
  };
}
