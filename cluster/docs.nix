{ kubenix, vars, flake, ... }:
flake.lib.recursiveMerge [
  {
    helm.releases.paperless-redis = {
      chart = kubenix.lib.helm.fetch {
        repo = "https://charts.bitnami.com/bitnami";
        chart = "redis";
        version = "17.4.1";
        sha256 = "sha256-UHYtPTg69jUU5fs7AcbRWNT184W3/nCWGqBGvi8seFI=";
      };
      values = {
        architecture = "standalone";
        auth.enabled = false;
        global.storageClass = "longhorn-static";
        image = {
          repository = "redis";
          tag = "7.0.7";
        };
      };
    };
  }

  (vars.simple {
    inherit kubenix;
    image = "paperlessngx/paperless-ngx:1.11";
    port = 8000;
    host = "docs";
    persistence = {
      main = {
        size = "10Gi";
        mountPath = "/paperless";
      };
      consume = {
        mountPath = "/paperless/consume";
        accessMode = "ReadWriteMany";
      };
    };
    values = {
      env = {
        PAPERLESS_URL = "https://docs.${flake.hostname}";
        PAPERLESS_CONSUMPTION_DIR = "/paperless/consume";
        PAPERLESS_DATA_DIR = "/paperless/data";
        PAPERLESS_MEDIA_ROOT = "/paperless/media";
        PAPERLESS_TRASH_DIR = "/paperless/trash";

        PAPERLESS_DBHOST = "postgresql.system";
        PAPERLESS_DBPASS = vars.secret "/postgresql/paperless";

        PAPERLESS_REDIS = "redis://paperless-redis-headless:6379";
      };
    };
  })

]
