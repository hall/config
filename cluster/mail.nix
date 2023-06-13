{ kubenix, flake, vars, ... }: {
  kubernetes.resources.ingressroutetcp = {
    imap.spec = {
      entryPoints = [ "imap" ];
      tls = { };
      routes = [{
        match = "HostSNI(`*`)";
        services = [{
          name = "protonmail-bridge";
          port = 143;
        }];
      }];
    };
    smtp.spec = {
      entryPoints = [ "smtp" ];
      tls = { };
      routes = [{
        match = "HostSNI(`*`)";
        services = [{
          name = "protonmail-bridge";
          port = 25;
        }];
      }];
    };
  };

  submodules.instances.protonmail-bridge = {
    submodule = "release";
    args = {
      image = "shenxn/protonmail-bridge:2.4.5-build";
      values = {
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
  };
}
