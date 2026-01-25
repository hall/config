{ flake, ... }: {
  imports = [
    ./adguard.nix
  ];

  networking = {
    # Use systemd-networkd for better control
    useNetworkd = true;
    useDHCP = false;

    # Disable default interface configuration
    interfaces = { };

    nat = {
      enable = true;
      externalInterface = "wan0"; # WAN interface (USB Ethernet)
      internalInterfaces = [ "lan0" ]; # LAN interface (Built-in Ethernet)
      internalIPs = [ "192.168.1.0/24" ];
    };

    firewall = {
      enable = true;

      # Allow DHCP and DNS on LAN interface
      interfaces.lan0 = {
        allowedTCPPorts = [
          53 # DNS
          3000 # AdGuard Home
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

    nameservers = [
      "127.0.0.1" # Local AdGuard Home
      "1.1.1.1" # Cloudflare fallback
      "1.0.0.1"
    ];
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
      # Match USB ethernet adapters by common drivers
      matchConfig.Driver = "r8152 asix ax88179_178a cdc_ether cdc_ncm";
      linkConfig.Name = "wan0";
    };

    # LAN interface (Built-in Ethernet)
    # Matches the built-in ethernet by path or driver
    links."20-lan" = {
      # Raspberry Pi 4 built-in ethernet uses this driver
      matchConfig.Driver = "bcmgenet";
      linkConfig.Name = "lan0";
    };

    # Configure WAN interface to get DHCP from ISP
    networks."30-wan" = {
      matchConfig.Name = "wan0";
      networkConfig = {
        DHCP = "ipv4";
        IPv6AcceptRA = true;
      };
      dhcpV4Config.UseDNS = false; # Use our own DNS (AdGuard Home)
    };

    # Configure LAN interface with static IP
    networks."40-lan" = {
      matchConfig.Name = "lan0";
      networkConfig = {
        Address = "192.168.1.1/24";
        DHCPServer = false; # AdGuard Home handles DHCP
        IPv6SendRA = true;
      };
      addresses = [
        { Address = "fd00::1/64"; } # ULA for internal IPv6
      ];
      ipv6SendRAConfig = {
        Managed = false; # SLAAC, not DHCPv6
        OtherInformation = false;
        DNS = "fd00::1"; # Advertise router as DNS server
      };
      ipv6Prefixes = [
        { Prefix = "fd00::/64"; }
      ];
    };
  };
}
