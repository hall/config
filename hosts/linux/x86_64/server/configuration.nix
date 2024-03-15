# NUC11PAHi7, 88:AE:DD:05:C9:46, F2 and/or ESC to enter bios
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

  age = {
    rekey.hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFt04Q7AY48Q5tJxFPxjJ3BZpBaR++R0jHRq7JVtBbkL";
    secrets = {
      namecheap.rekeyFile = ./namecheap.age;
      restic.rekeyFile = ./restic.age;
      rclone.rekeyFile = ./rclone.age;
    };
  };

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
      extraUpFlags = [ "--ssh" ];
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
          rewrites = [{
            domain = "*.${flake.lib.hostname}";
            answer = "192.168.86.2";
          }];
        };
        dhcp = {
          enabled = true;
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
      user = flake.lib.username;
      group = "syncthing";
    };

    syncthing.settings.folders.stash.path = lib.mkForce "/var/lib/stash";

    # manually trigger with: `systemctl start restic-backups-remote`
    # restic -r rclone:remote:/backups restore <id> --target <path>
    # restic mount ...
    # rclone about remote:
    restic.backups.remote = {
      initialize = true;
      paths = lib.mapAttrsToList (name: folder: folder.path) config.services.syncthing.settings.folders;
      repository = "rclone:gdrive:/backup";
      passwordFile = config.age.secrets.rclone.path;
      environmentFile = config.age.secrets.restic.path;
      extraBackupArgs = [ "--fast-list" ];
      timerConfig.OnCalendar = "sunday 23:00";
    };

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
