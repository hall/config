# Router Networking Configuration
# WAN: USB Ethernet adapter (wan0)
# LAN: Built-in Ethernet (lan0)
{ flake, config, lib, pkgs, ... }: {
  networking = {
    hostName = "router";

    # Use systemd-networkd for better control
    useNetworkd = true;
    useDHCP = false;

    # Disable default interface configuration
    interfaces = { };

    # NAT configuration
    nat = {
      enable = true;
      externalInterface = "wan0"; # WAN interface (USB Ethernet)
      internalInterfaces = [ "lan0" ]; # LAN interface (Built-in Ethernet)
      internalIPs = [ "192.168.1.0/24" ];
    };

    # Firewall configuration
    firewall = {
      enable = true;

      # Allow DHCP and DNS on LAN interface
      interfaces.lan0 = {
        allowedTCPPorts = [
          53 # DNS
          80 # HTTP (for AdGuard Home web interface)
          443 # HTTPS
          3000 # AdGuard Home alternative port
        ];
        allowedUDPPorts = [
          53 # DNS
          67 # DHCP server
          68 # DHCP client
        ];
      };

      # WAN interface - restrictive by default
      interfaces.wan0 = {
        allowedTCPPorts = [ ];
        allowedUDPPorts = [ ];
      };

      # Allow ping
      allowPing = true;

      # Extra commands for advanced routing
      extraCommands = ''
        # Allow established connections
        iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

        # Allow all from LAN
        iptables -A INPUT -i lan0 -j ACCEPT

        # Log dropped packets (optional, comment out if too verbose)
        # iptables -A INPUT -j LOG --log-prefix "DROPPED: "
      '';
    };

    # DNS configuration
    nameservers = [
      "127.0.0.1" # Local AdGuard Home
      "1.1.1.1" # Cloudflare fallback
      "1.0.0.1"
    ];
  };

  # AdGuard Home configuration
  services.adguardhome = {
    enable = true;
    mutableSettings = false;
    openFirewall = true;

    host = "0.0.0.0";
    port = 3000;
    settings = {
      dns = {
        bind_hosts = [ "192.168.1.1" ];
        port = 53;

        # Upstream DNS servers
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

        # Enable DNS caching
        cache_size = 4194304;
        cache_ttl_min = 60;
        cache_ttl_max = 86400;

        # Security
        enable_dnssec = true;

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

        # Static DHCP leases (optional)
        # dhcp_static_leases = [
        #   {
        #     mac = "aa:bb:cc:dd:ee:ff";
        #     ip = "192.168.1.10";
        #     hostname = "mydevice";
        #   }
        # ];
      };

      filtering = {
        protection_enabled = true;
        filtering_enabled = true;

        rewrites = [
          {
            domain = "router.lan";
            answer = "192.168.1.1";
          }
          {
            domain = "*.${flake.lib.hostname}";
            answer = "192.168.1.1";
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

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "both";
    extraUpFlags = [
      "--operator=${flake.lib.username}"
      "--ssh"
      "--advertise-routes=192.168.1.0/24"
      "--accept-routes"
    ];
  };

  # Optional: Enable persistent storage for important data
  # Uncomment if using impermanence module
  # environment.persistence."/persist" = {
  #   directories = [
  #     "/var/lib/tailscale"
  #     "/var/lib/private/AdGuardHome"
  #   ];
  # };

  systemd.network = {
    enable = true;

    # WAN interface (USB Ethernet adapter)
    # Matches any USB ethernet device
    links."10-wan" = {
      matchConfig = {
        # Match USB ethernet adapters by common drivers
        Driver = "r8152 asix ax88179_178a cdc_ether cdc_ncm";
      };
      linkConfig = {
        Name = "wan0";
      };
    };

    # LAN interface (Built-in Ethernet)
    # Matches the built-in ethernet by path or driver
    links."20-lan" = {
      matchConfig = {
        # Raspberry Pi 4 built-in ethernet uses this driver
        Driver = "bcmgenet";
      };
      linkConfig = {
        Name = "lan0";
      };
    };

    # Configure WAN interface to get DHCP from ISP
    networks."30-wan" = {
      matchConfig.Name = "wan0";
      networkConfig = {
        DHCP = "ipv4";
        IPv6AcceptRA = true;
      };
      dhcpV4Config = {
        UseDNS = false; # Use our own DNS (AdGuard Home)
      };
    };

    # Configure LAN interface with static IP
    networks."40-lan" = {
      matchConfig.Name = "lan0";
      networkConfig = {
        Address = "192.168.1.1/24";
        DHCPServer = false; # AdGuard Home handles DHCP
      };
    };
  };
}
