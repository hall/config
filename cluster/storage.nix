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
      recurringjobs.default = {
        metadata.namespace = ns;
        spec = {
          cron = "0 0 * * *";
          task = "backup";
          groups = [ "default" ];
          retain = 1;
          concurrency = 5;
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
        version = "v1.4.2";
        sha256 = "wObUgcGMJtr8s5xpyfahjBm1roQyP4+nySeF/EkUWkg=";
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
        longhornConversionWebhook.replicas = 1;
        longhornAdmissionWebhook.replicas = 1;
        longhornRecoveryBackend.replicas = 1;
        longhornManager.tolerations = [{
          key = "node-role.kubernetes.io/control-plane";
          operator = "Exists";
          effect = "NoSchedule";
        }];
      };
    };
    customTypes = {
      recurringjobs = {
        attrName = "recurringjobs";
        group = "longhorn.io";
        version = "v1beta1";
        kind = "RecurringJob";
      };
    };
  };
}
