{ config, flake, ... }: {
  networking = {
    useNetworkd = true;
    useDHCP = false;
    interfaces = { };

    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
      allowedUDPPorts = [ ];
      allowPing = true;
    };
  };

  services.hostapd = {
    enable = true;
    radios.wlan0 = {
      band = "2g";
      channel = 6;
      countryCode = "US";
      wifi4 = {
        enable = true;
        capabilities = [ "HT40+" "SHORT-GI-20" "SHORT-GI-40" ];
      };
      networks.wlan0 = {
        ssid = "hall";
        authentication = {
          mode = "wpa2-sha256";
          wpaPasswordFile = config.age.secrets.wifi.path;
        };
        bssid = "02:00:00:00:00:01";
      };
    };
    radios.wlan1 = {
      band = "5g";
      channel = 36;
      countryCode = "US";
      wifi4 = {
        enable = true;
        capabilities = [ "HT40+" "SHORT-GI-20" "SHORT-GI-40" ];
      };
      wifi5 = {
        enable = true;
        capabilities = [ "SHORT-GI-80" "SU-BEAMFORMEE" ];
        operatingChannelWidth = "80";
      };
      networks.wlan1 = {
        ssid = "hall";
        authentication = {
          mode = "wpa2-sha256";
          wpaPasswordFile = config.age.secrets.wifi.path;
        };
        bssid = "02:00:00:00:00:02";
      };
    };
  };

  age.secrets.wifi.rekeyFile = ../../../../modules/wifi/wifi.age;

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
    extraUpFlags = [
      "--operator=${flake.lib.username}"
      "--ssh"
      "--accept-routes"
    ];
  };

  systemd.network = {
    enable = true;
    netdevs."10-br0" = {
      netdevConfig = {
        Name = "br0";
        Kind = "bridge";
      };
    };

    links."20-eth" = {
      matchConfig.Driver = "bcmgenet";
      linkConfig.Name = "eth0";
    };

    networks."30-eth" = {
      matchConfig.Name = "eth0";
      networkConfig.Bridge = "br0";
    };

    networks."40-wlan0" = {
      matchConfig.Name = "wlan0";
      networkConfig.Bridge = "br0";
    };

    networks."41-wlan1" = {
      matchConfig.Name = "wlan1";
      networkConfig.Bridge = "br0";
    };

    networks."50-br0" = {
      matchConfig.Name = "br0";
      networkConfig.DHCP = "ipv4";
      linkConfig.RequiredForOnline = "routable";
    };
  };
}
