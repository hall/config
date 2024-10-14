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
    wifi.enable = true;

    tailscale = {
      enable = true;
      useRoutingFeatures = "both";
      extraSetFlags = [
        "--operator=${flake.lib.username}"
        "--ssh"
        # "--advertise-exit-node"
        # "--exit-node-allow-lan-access"
        # "--exit-node=us-nyc-wg-303.mullvad.ts.net."
      ];
    };

    adguardhome = {
      enable = true;
      mutableSettings = false;
      settings = {
        dns = {
          bind_host = "127.0.0.1";
          bootstrap_dns = [
            "9.9.9.10"
            "149.112.112.10"
            "2620:fe::10"
            "2620:fe::fe:10"
          ];
        };
        filtering = {
          rewrites = [
            {
              # NOTE: this is just for split DNS, actual record in namecheap
              domain = "grafana.${flake.lib.hostname}";
              answer = "thehalls.grafana.net";
            }
            {
              domain = "*.${flake.lib.hostname}";
              answer = "192.168.86.2";
            }
          ];
        };
        dhcp = {
          enabled = false;
          interface_name = "wlo1";
          dhcpv4 = {
            gateway_ip = "192.168.86.1";
            subnet_mask = "255.255.255.0";
            range_start = "192.168.86.10";
            range_end = "192.168.86.254";
          };
        };
      };
    };

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
          locations."/".proxyPass = "http://127.0.0.1:3000";
        };
        "sync.${flake.lib.hostname}" = {
          useACMEHost = flake.lib.hostname;
          acmeRoot = null;
          forceSSL = true;
          locations."/".proxyPass = "http://${builtins.toString config.services.syncthing.guiAddress}";
          extraConfig = ''
            proxy_read_timeout      600s;
            proxy_send_timeout      600s;
          '';
        };
        "stash.${flake.lib.hostname}" = {
          useACMEHost = flake.lib.hostname;
          acmeRoot = null;
          forceSSL = true;
          locations."/".proxyPass = "http://127.0.0.1:${builtins.toString config.services.stash.port}";
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
