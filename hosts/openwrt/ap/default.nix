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
  ];

  # unused defaults; dhcp is disabled on lan and the APs don't route
  uci.retain = [
    "dhcp"
    "firewall"
    "ubihealthd"
  ];

  # the router serves DHCP and DNS
  disabledServices = [
    "dnsmasq"
    "odhcpd"
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

    # TODO: one wifi-iface per VLAN SSID, plus 802.11r across APs
    wireless = {
      wifi-device = lib.mapAttrs (
        _: r:
        r
        // {
          type = "mac80211";
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
        }
      ) radios;
    };
  };
}
