{ kubenix, vars, flake, ... }: {
  kubernetes.helm.releases.paperless-redis = {
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
  submodules.instances.paperless = {
    submodule = "release";
    args = {
      image = "paperlessngx/paperless-ngx:1.13";
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
        ingress.main.annotations = {
          "traefik.ingress.kubernetes.io/router.middlewares" = "kube-system-home@kubernetescrd";
        };
        env = {
          PAPERLESS_URL = "https://docs.${flake.lib.hostname}";
          PAPERLESS_CONSUMPTION_DIR = "/paperless/consume";
          PAPERLESS_DATA_DIR = "/paperless/data";
          PAPERLESS_MEDIA_ROOT = "/paperless/media";
          PAPERLESS_TRASH_DIR = "/paperless/trash";

          PAPERLESS_DBHOST = "postgresql";
          PAPERLESS_DBPASS = vars.secret "/postgresql/paperless";

          PAPERLESS_REDIS = "redis://paperless-redis-headless:6379";
          # this var which clashes with k8s
          PAPERLESS_PORT = "8000";

          PAPERLESS_CONSUMER_DELETE_DUPLICATES = "true";
          PAPERLESS_AUTO_LOGIN_USERNAME = "hall";
        };
      };
    };
  };
}
