# shared config for Cudy AP3000 (mediatek/filogic) dumb APs
{ lib, network, ... }:
let
  radios = {
    radio0 = {
      path = "platform/soc/18000000.wifi";
      band = "2g";
      htmode = "HE20";
    };
    radio1 = {
      path = "platform/soc/18000000.wifi+1";
      band = "5g";
      htmode = "HE80";
    };
  };
in
{
  packages = [
    "prometheus-node-exporter-lua-wifi"
    "prometheus-node-exporter-lua-wifi_stations"
    "usteer"
  ];

  # the basic variant lacks 802.11k/v, so usteer could only kick clients, not ask them to move
  providers.wpad-basic-mbedtls = "wpad-mbedtls";

  # a deployer on this AP's wifi has to reassociate before it can confirm
  deploy.rollbackTimeout = 120;

  # unused defaults; dhcp is disabled on lan and the APs don't route
  uci.retain = [
    "dhcp"
    "firewall"
    "ubihealthd"
  ];

  # the router serves DHCP and DNS, and the APs don't route
  disabledServices = [
    "dnsmasq"
    "odhcpd"
    "firewall"
  ];

  uci.settings = {

    network = {
      globals.globals.packet_steering = true;
      device = [
        {
          name = "br-lan";
          type = "bridge";
          ports = "eth0";
        }
      ];
      interface.lan = {
        device = "br-lan";
        proto = "dhcp";
        multipath = "off";
      };
    };

    # TODO: one wifi-iface per VLAN SSID
    wireless = {
      wifi-device = lib.mapAttrs (
        _: r:
        r
        // {
          type = "mac80211";
          # without it the world domain applies: 149-165 are passive-only and power is capped
          country = "US";
          channel = lib.mkDefault "auto";
          cell_density = 0;
        }
      ) radios;
      wifi-iface = lib.mapAttrs' (
        radio: _:
        lib.nameValuePair "default_${radio}" {
          device = radio;
          network = "lan";
          mode = "ap";
          inherit (network) ssid;
          encryption = "psk2";
          key._secret = "wifi";
          # fast roaming; with a PSK each AP derives the FT keys itself, so no key holder lists
          ieee80211r = true;
          mobility_domain = "4f57";
          ft_over_ds = false;
          ft_psk_generate_local = true;
          # neighbor reports and BSS transition requests, used by usteer
          ieee80211k = true;
          bss_transition = true;
        }
      ) radios;
    };

    # conservative start: nudge weak clients via 802.11v, never kick on load
    usteer.usteer = [
      {
        network = "lan";
        syslog = true;
        local_mode = false;
        ipv6 = false;
        debug_level = 2;
        # dBm (negative values are absolute signal, not SNR)
        roam_scan_snr = -70;
        roam_trigger_snr = -75;
        signal_diff_threshold = 8;
      }
    ];
  };
}
