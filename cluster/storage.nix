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
        concurrency = 1;
      };
    };
  };
  helm.releases.longhorn = {
    chart = kubenix.lib.helm.fetch {
      repo = "https://charts.longhorn.io";
      chart = "longhorn";
      version = "v1.3.2";
      sha256 = "sha256-jZ0yqrSg7oo6i849y+vcrXwGC75TrDliD9nijdz7wlM=";
    };
    namespace = ns;
    values = {
      defaultSettings = {
        backupTarget = "s3://storage.${flake.hostname}@nyc3/";
        backupTargetCredentialSecret = creds;
      };
      ingress = {
        enabled = true;
        host = "longhorn.${flake.hostname}";
      };
      persistence = {
        defaultClass = false;
        reclaimPolicy = "Retain";
      };
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
