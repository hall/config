{ kubenix, flake, vars, ... }:
let
  ns = "longhorn-system";
  creds = "digitalocean";
in
{
  kubernetes = {
    resources = {
      namespaces.${ns}.metadata.labels = {
        "goldilocks.fairwinds.com/enabled" = "true";
        "goldilocks.fairwinds.com/vpa-update-mode" = "auto";
      };
      secrets.${creds} = {
        metadata.namespace = ns;
        stringData = {
          AWS_ACCESS_KEY_ID = vars.secret "/cloud/id";
          AWS_SECRET_ACCESS_KEY = vars.secret "/cloud/secret";
          AWS_ENDPOINTS = "https://nyc3.digitaloceanspaces.com";
        };
      };
      recurringjobs = {
        backup = {
          metadata.namespace = ns;
          spec = {
            cron = "0 0 1 * *"; # monthly
            task = "backup";
            groups = [ "default" ];
            retain = 12; # 1 year
            concurrency = 5;
          };
        };
        snapshot = {
          metadata.namespace = ns;
          spec = {
            cron = "0 0 * * *"; # daily
            task = "snapshot";
            groups = [ "default" ];
            retain = 30; # ~1 month
            concurrency = 5;
          };
        };
        # opt out with an annotation on the volume:
        #   recurring-job.longhorn.io/disabled=enabled
        disabled = {
          metadata.namespace = ns;
          # https://stackoverflow.com/a/13938155
          spec.cron = "0 0 31 2 ?";
        };
      };
      # TODO: workaround
      daemonSets.longhorn-manager = {
        metadata.namespace = ns;
        spec.template.spec.containers.longhorn-manager.env = [{
          name = "PATH";
          value = "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/run/wrappers/bin:/run/current-system/sw/bin";
        }];
      };
    };
    helm.releases.longhorn = {
      chart = kubenix.lib.helm.fetch {
        repo = "https://charts.longhorn.io";
        chart = "longhorn";
        version = "v1.5.1";
        sha256 = "J8rrygBavwa0c2J8jWa+9VuUwczBOewBui5KzP5YRMw=";
      };
      noHooks = true;
      namespace = ns;
      values = {
        defaultSettings = {
          backupTarget = "s3://backup.${flake.lib.hostname}@nyc3/";
          backupTargetCredentialSecret = creds;
          replicaAutoBalance = "best-effort";
          orphanAutoDeletion = true;
          concurrentAutomaticEngineUpgradePerNodeLimit = 3;
          taintToleration = "node-role.kubernetes.io/control-plane=effect:NoSchedule";
        };
        ingress = {
          enabled = true;
          host = "longhorn.${flake.lib.hostname}";
        };
        persistence = {
          defaultClass = false;
          reclaimPolicy = "Retain";
        };
        longhornUI.replicas = 1;
        longhornManager.tolerations = [{
          key = "node-role.kubernetes.io/control-plane";
          operator = "Exists";
          effect = "NoSchedule";
        }];
      };
    };
    customTypes.recurringjobs = {
      attrName = "recurringjobs";
      group = "longhorn.io";
      version = "v1beta1";
      kind = "RecurringJob";
    };
  };
}
