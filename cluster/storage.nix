{ kubenix, flake, vars, ... }:
let
  ns = "longhorn-system";
  creds = "digitalocean";
in
{
  resources = {
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
  };
  helm.releases.longhorn = {
    chart = kubenix.lib.helm.fetch {
      repo = "https://charts.longhorn.io";
      chart = "longhorn";
      version = "v1.4.2";
      sha256 = "wObUgcGMJtr8s5xpyfahjBm1roQyP4+nySeF/EkUWkg=";
    };
    namespace = ns;
    values = {
      defaultSettings = {
        backupTarget = "s3://backup.${flake.lib.hostname}@nyc3/";
        backupTargetCredentialSecret = creds;
        replicaAutoBalance = "best-effort";
        orphanAutoDeletion = true;
        concurrentAutomaticEngineUpgradePerNodeLimit = 3;
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
    };
    # patches = {
    #   resources.daemonset.longhorn-manager.spec.template.spec.containers = {
    #     longhorn-manager.env.PATH = "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/run/wrappers/bin:/run/current-system/sw/bin";
    #   };
    #   TODO: undo temp symlinks:
    #   for app in bash flock stat lsblk mount iscsiadm; do sudo ln -s /run/current-system/sw/bin/$app /bin/$app; done
    # };
  };
  customTypes = {
    recurringjobs = {
      attrName = "recurringjobs";
      group = "longhorn.io";
      version = "v1beta1";
      kind = "RecurringJob";
    };
  };
}
