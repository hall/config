# NUC11PAHi7, 88:AE:DD:05:C9:46, F2 to enter bios
# TODO
# - circadian lighting
# - connect
#   - switches: https://www.indiegogo.com/projects/mmwave-smart-switch-with-presence-sensing-radar
#   - led controllers
#   - konnected: https://www.reddit.com/r/konnected/comments/15pom5f/any_update_on_matter_support/
#   - power monitoring?
#   - mailbox?
{ lib, pkgs, flake, config, ... }: {
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  networking = {
    firewall = {
      allowedTCPPorts = [
        80 # http redirect
        443 # https
        53 # dns fallback
      ];
      allowedUDPPorts = [
        53 # dns
        67 # dhcp
        68 # dhcp
      ];
    };
  };

  age.secrets.namecheap.file = ../../../../secrets/namecheap.age;
  security.acme = {
    acceptTerms = true;
    defaults = {
      email = flake.lib.email;
      group = "nginx";
      dnsProvider = "namecheap";
      credentialsFile = "/run/secrets/namecheap";
    };
    certs."${flake.lib.hostname}".domain = "*.${flake.lib.hostname}";
  };

  services = {
    wifi.enable = true;

    adguardhome = {
      enable = true;
      # mutableSettings = false;
      settings = {
        bind_host = "127.0.0.1";
        # bootstrap_dns
        filtering.rewrites = [{
          domain = "*.${flake.lib.hostname}";
          answer = "10.0.0.2";
        }];
        dhcp = {
          enabled = true;
          interface_name = "wlo1";
          dhcpv4 = {
            gateway_ip = "10.0.0.1";
            subnet_mask = "255.255.255.0";
            range_start = "10.0.0.10";
            range_end = "10.0.0.254";
          };
        };
      };
    };

    nginx = {
      enable = true;
      # recommendedGzipSettings = true;
      # recommendedOptimisation = true;
      # recommendedProxySettings = true;
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

    stash = {
      # /var/lib/stash  # app data
      enable = true;
      group = "syncthing";
    };

    syncthing.settings.folders.stash.path = lib.mkForce "/var/lib/stash";

    iperf3 = {
      enable = true;
      openFirewall = true;
    };
  };

  environment.systemPackages = with pkgs; [
    iperf
    htop
  ];

}
