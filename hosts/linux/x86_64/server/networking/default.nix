{ flake, config, ... }: {
  age.secrets.namecheap.rekeyFile = ./namecheap.age;

  security.acme = {
    acceptTerms = true;
    defaults = {
      email = flake.lib.email;
      group = "nginx";
      dnsProvider = "namecheap";
      environmentFile = config.age.secrets.namecheap.path;
    };
    certs."${flake.lib.hostname}".domain = "*.${flake.lib.hostname}";
  };

  services = {
    tailscale = {
      enable = true;
      useRoutingFeatures = "both";
      extraUpFlags = [
        "--operator=${flake.lib.username}"
        "--ssh"
        # "--advertise-exit-node"
        "--exit-node-allow-lan-access"
        #"--exit-node=us-nyc-wg-604.mullvad.ts.net"
        "--advertise-routes=192.168.1.0/24"
      ];
      extraSetFlags = [
        "--advertise-connector"
      ];
    };

    syncthing.guiAddress = "0.0.0.0:8384";

    nginx = {
      enable = true;
      # recommendedGzipSettings = true;
      # recommendedOptimisation = true;
      recommendedProxySettings = true;
      # recommendedTlsSettings = true;

      virtualHosts = {
        "adguard.${flake.lib.hostname}" = {
          useACMEHost = flake.lib.hostname;
          acmeRoot = null;
          forceSSL = true;
          locations."/".proxyPass = "http://192.168.1.1:3000";
        };
        "sync.${flake.lib.hostname}" = {
          useACMEHost = flake.lib.hostname;
          acmeRoot = null;
          forceSSL = true;
          locations."/".proxyPass = "http://${builtins.toString config.services.syncthing.guiAddress}";
          extraConfig = ''
            proxy_set_header        Host localhost;
            proxy_set_header        X-Real-IP $remote_addr;
            proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header        X-Forwarded-Proto $scheme;
          
            proxy_read_timeout      600s;
            proxy_send_timeout      600s;
          '';
        };
        "home.${flake.lib.hostname}" = {
          useACMEHost = flake.lib.hostname;
          acmeRoot = null;
          forceSSL = true;
          extraConfig = ''
            proxy_buffering off;
          '';
          locations."/" = {
            proxyPass = "http://homeassistant.lan:8123";
            proxyWebsockets = true;
          };
        };
        "stash.${flake.lib.hostname}" = {
          useACMEHost = flake.lib.hostname;
          acmeRoot = null;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:${builtins.toString config.services.stash.settings.port}";
            proxyWebsockets = true;
          };
          extraConfig = ''
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_read_timeout 60000s;
          '';
        };
      };
    };
  };

}
