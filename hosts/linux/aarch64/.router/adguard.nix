{ flake, ... }: {
  # Ensure network is fully configured before AdGuard starts
  systemd.services.adguardhome = {
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
  };

  services.adguardhome = {
    enable = true;
    mutableSettings = false;
    openFirewall = true;
    settings = {
      dns = {
        bind_hosts = [ "192.168.1.1" ];
        port = 53;

        bootstrap_dns = [
          "1.1.1.1"
          "1.0.0.1"
          "2606:4700:4700::1111"
          "2606:4700:4700::1001"
        ];

        upstream_dns = [
          "https://dns.cloudflare.com/dns-query"
          "https://dns.google/dns-query"
        ];

        cache_size = 4194304;
        cache_ttl_min = 60;
        cache_ttl_max = 86400;

        enable_dnssec = true;

        # Resolve reverse DNS for local addresses from DHCP leases
        use_private_ptr_resolvers = true;
        local_ptr_upstreams = [ ];

        # Performance
        all_servers = false;
        fastest_addr = true;
      };

      dhcp = {
        enabled = true;
        interface_name = "lan0";

        dhcpv4 = {
          gateway_ip = "192.168.1.1";
          subnet_mask = "255.255.255.0";
          range_start = "192.168.1.100";
          range_end = "192.168.1.254";
          lease_duration = 86400; # 24 hours
        };

        dhcp_static_leases = [
          {
            mac = "88:ae:dd:05:c9:46";
            ip = "192.168.1.10";
            hostname = "server";
          }
          {
            mac = "88:15:44:60:14:88";
            ip = "192.168.1.2";
            hostname = "switch";
          }
          # {
          #   # prevent wan0 DHCP discovers from creating dynamic leases
          #   mac = "5c:85:7e:31:64:25";
          #   ip = "192.168.1.1";
          #   hostname = "router";
          # }
        ];
      };

      filtering = {
        protection_enabled = true;
        filtering_enabled = true;

        rewrites = [
          {
            domain = "router.lan";
            answer = "192.168.1.1";
            enabled = true;
          }
          {
            domain = "server";
            answer = "192.168.1.10";
            enabled = true;
          }
          {
            domain = "*.${flake.lib.hostname}";
            # nginx runs here - resolves via "server" rewrite above
            answer = "server";
            enabled = true;
          }
          {
            # NOTE: this is just for split DNS, actual record in namecheap
            domain = "grafana.${flake.lib.hostname}";
            answer = "thehalls.grafana.net";
            enabled = true;
          }
        ];
      };

      filters = [
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt";
          name = "AdGuard DNS filter";
          id = 1;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_2.txt";
          name = "AdAway Default Blocklist";
          id = 2;
        }
      ];

      querylog = {
        enabled = true;
        interval = "24h";
        size_memory = 1000;
      };

      statistics = {
        enabled = true;
        interval = "24h";
      };
    };
  };
}
