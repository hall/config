# FriendlyElec NanoPi R5C (rockchip/armv8)
{ lib, network, ... }:
let
  wan = "eth1";
  lan = "eth0";
in
{
  imports = [
    ./adblock.nix
    ./dhcp.nix
    ./firewall.nix
  ];

  system.log_size = 2048;

  packages = [
    "luci-app-sqm"
    "prometheus-node-exporter-lua-nat_traffic"
    "prometheus-node-exporter-lua-wifi"
    "prometheus-node-exporter-lua-wifi_stations"
    "tcpdump"
  ];

  # rtw88 radio is present but unconfigured
  uci.retain = [ "wireless" ];

  # neither picks up config changes on `--reload`, and https-dns-proxy starts
  # with its package defaults when first installed
  restartServices = [
    "https-dns-proxy"
    "adblock"
  ];

  uci.settings = {
    # admin services never listen on WAN, even if a firewall rule slips
    dropbear.dropbear.main.Interface = "lan";
    uhttpd.uhttpd.main = {
      listen_http = [ "${network.lan.address}:80" ];
      listen_https = [ "${network.lan.address}:443" ];
    };

    network = {
      globals.globals = {
        dhcp_default_duid = "000485ddc75019f34072b4b41bf2a586368d";
        ula_prefix = "fdfd:9b28:abb::/48";
      };
      device = [
        {
          name = "br-lan";
          type = "bridge";
          ports = lan;
        }
        {
          name = lan;
          macaddr = "72:83:63:88:9f:4c";
        }
        {
          name = wan;
          macaddr = "72:83:63:88:9f:4b";
        }
      ];
      interface = {
        lan = {
          device = "br-lan";
          proto = "static";
          ipaddr = "${network.lan.address}/${toString network.lan.prefix}";
          ip6assign = 60;
        };
        wan = {
          device = wan;
          proto = "dhcp";
        };
        wan6 = {
          device = wan;
          proto = "dhcpv6";
          reqaddress = "try";
          reqprefix = "auto";
          norelease = true;
          multipath = "off";
        };
      };
    };

    # upstream for the rest of the network
    system.timeserver.ntp = {
      server = map (i: "${toString i}.openwrt.pool.ntp.org") (lib.range 0 3);
      enable_server = true;
      interface = "lan";
    };

    sqm.queue.eth1 = {
      enabled = true;
      interface = wan;
      download = 846000;
      upload = 846000;
      qdisc = "cake";
      script = "layer_cake.qos";
      linklayer = "ethernet";
      overhead = 44;
      use_mq = false;
      debug_logging = false;
      verbosity = 5;
    };

    system.led =
      lib.mapAttrs
        (_: dev: {
          name = lib.toUpper dev.label;
          sysfs = "green:${dev.label}";
          trigger = "netdev";
          mode = "link tx rx";
          inherit (dev) dev;
        })
        {
          led_wan = {
            label = "wan";
            dev = wan;
          };
          led_lan = {
            label = "lan";
            dev = lan;
          };
          led_wlan = {
            label = "wlan";
            dev = "phy0-ap0";
          };
        };
  };
}
