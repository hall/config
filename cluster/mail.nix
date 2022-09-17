{ kubenix, flake, vars, ... }:
let
  ns = "default";
in
{
  resources.ingressroutetcp = {
    imap = {
      metadata.namespace = ns;
      spec = {
        entryPoints = [ "imap" ];
        tls = { };
        routes = [{
          match = "HostSNI(`*`)";
          services = [{
            name = "protonmail-bridge";
            port = 143;
            namespace = ns;
          }];
        }];
      };
    };
    smtp = {
      metadata.namespace = ns;
      spec = {
        entryPoints = [ "smtp" ];
        tls = { };
        routes = [{
          match = "HostSNI(`*`)";
          services = [{
            name = "protonmail-bridge";
            port = 25;
            namespace = ns;
          }];
        }];
      };
    };
  };
  helm.releases.protonmail-bridge = {
    chart = vars.template { inherit kubenix; };
    namespace = ns;
    values = {
      image = {
        repository = "shenxn/protonmail-bridge";
        tag = "2.3.0-build";
      };
      service.main.ports = {
        http.enabled = false;
        smtp = {
          enabled = true;
          primary = true;
          port = 25;
        };
        imap = {
          enabled = true;
          port = 143;
        };
      };
      persistence.config = {
        enabled = true;
        mountPath = "/root";
        storageClass = "longhorn-static";
      };
    };
  };
}
