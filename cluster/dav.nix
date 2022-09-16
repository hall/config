{ kubenix, flake, vars, ... }:
{
  helm.releases.dav = {
    chart = vars.template { inherit kubenix; };
    namespace = "default";
    values = {
      image = {
        repository = "tomsquest/docker-radicale";
        tag = "3.1.1.0";
      };
      env.RADICALE_CONFIG = "/config/config";
      service.main.ports.http.port = 5232;
      ingress.main = {
        enabled = true;
        hosts = [{
          host = "dav.${flake.hostname}";
          paths = [{ path = "/"; }];
        }];
      };
      persistence = {
        data = {
          enabled = true;
          accessMode = "ReadWriteOnce";
          size = "10Gi";
          storageClass = "longhorn-static";
        };
        config = {
          enabled = true;
          type = "configMap";
          # subPath = "config";
          name = "dav-config";
          readOnly = true;
        };
        htpasswd = {
          enabled = true;
          type = "secret";
          subPath = "htpasswd";
          name = "dav";
          readOnly = true;
        };
      };
      secret.htpasswd = vars.secret "/dav";
      configmap.config = {
        enabled = true;
        data.config = ''
          [server]
          hosts = 0.0.0.0:5232

          [auth]
          type = htpasswd
          htpasswd_filename = /htpasswd
          htpasswd_encryption = bcrypt

          [storage]
          filesystem_folder = /data/collections
        '';
      };
    };
  };
}
