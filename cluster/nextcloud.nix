# https://github.com/nextcloud/helm/tree/main/charts/nextcloud#running-occ-commands
{ kubenix, flake, vars, ... }: {
  kubernetes = {
    # TODO: redis b64 encodes their secret data which is incompatable with vals
    resources.secrets.nextcloud-redis.stringData.redis-password = vars.secret "/nextcloud/redis";
    helm.releases.nextcloud = {
      chart = kubenix.lib.helm.fetch {
        repo = "https://nextcloud.github.io/helm";
        chart = "nextcloud";
        version = "4.3.1";
        sha256 = "ycBIylzQq//UEovNfbmL0A7OBtuNfM9B6jaeXFOmXGU=";
      };
      values = {
        ingress = {
          enabled = true;
          annotations = {
            "traefik.ingress.kubernetes.io/router.middlewares" = "kube-system-cloud@kubernetescrd";
          };
        };
        nextcloud = {
          host = "cloud.${flake.lib.hostname}";
          username = "/nextcloud/username";
          password = vars.secret "/nextcloud/password";
          extraEnv = [
            {
              name = "PHP_MEMORY_LIMIT";
              value = "1G";
            }
            # {
            #   name = "PHP_UPLOAD_LIMIT";
            #   value = "1G";
            # }
          ];
          configs = {
            "proxy.config.php" = ''
              <?php
              $CONFIG = array (
                'trusted_proxies' => array(
                  0 => '127.0.0.1',
                  1 => '10.0.0.0/8',
                ),
                'forwarded_for_headers' => array('HTTP_X_FORWARDED_FOR'),
              );
            '';
          };
        };
        redis = {
          enabled = true;
          architecture = "standalone";
          auth = {
            # enabled = false;
            password = vars.secret "/nextcloud/redis";
          };
          global.storageClass = "longhorn-static";
          # TODO: colocate with redis
          # master.affinity.podAffinity.preferredDuringSchedulingIgnoredDuringExecution = [{
          #   weight = 50;
          #   podAffinityTerm = {
          #     topologyKey = "app.kubernetes.io/name";
          #     labelSelector.matchExpressions = [{
          #       key = "name";
          #       operator = "In";
          #       values = [ "nextcloud" ];
          #     }];
          #   };
          # }];
        };
        cronjob.enabled = true;
        externalDatabase = {
          type = "postgresql";
          host = "postgresql";
          password = vars.secret "/postgresql/nextcloud";
        };
        persistence = {
          enabled = true;
          storageClass = "longhorn-static";
          size = "100Gi";
        };
        deploymentAnnotations."goldilocks.fairwinds.com/vpa-update-mode" = "off";
        resources.requests = {
          cpu = "1";
          memory = "2Gi";
        };
      };
    };
  };
}
