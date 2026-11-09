{ network, ... }:
let
  inherit (network) hosts;
in
{
  uci.settings.firewall = {
    defaults = [
      {
        syn_flood = true;
        input = "REJECT";
        output = "ACCEPT";
        forward = "REJECT";
      }
    ];
    zone = [
      {
        name = "lan";
        network = "lan";
        input = "ACCEPT";
        output = "ACCEPT";
        forward = "ACCEPT";
      }
      {
        name = "wan";
        network = [
          "wan"
          "wan6"
        ];
        input = "REJECT";
        output = "ACCEPT";
        forward = "DROP";
        masq = true;
        mtu_fix = true;
      }
    ];
    forwarding = [
      {
        src = "lan";
        dest = "wan";
      }
    ];
    # OpenWrt defaults
    rule = [
      {
        name = "Allow-DHCP-Renew";
        src = "wan";
        proto = "udp";
        dest_port = 68;
        target = "ACCEPT";
        family = "ipv4";
      }
      {
        name = "Allow-Ping";
        src = "wan";
        proto = "icmp";
        icmp_type = "echo-request";
        family = "ipv4";
        target = "ACCEPT";
      }
      {
        name = "Allow-IGMP";
        src = "wan";
        proto = "igmp";
        family = "ipv4";
        target = "ACCEPT";
      }
      {
        name = "Allow-DHCPv6";
        src = "wan";
        proto = "udp";
        dest_port = 546;
        family = "ipv6";
        target = "ACCEPT";
      }
      {
        name = "Allow-MLD";
        src = "wan";
        proto = "icmp";
        src_ip = "fe80::/10";
        icmp_type = [
          "130/0"
          "131/0"
          "132/0"
          "143/0"
        ];
        family = "ipv6";
        target = "ACCEPT";
      }
      {
        name = "Allow-ICMPv6-Input";
        src = "wan";
        proto = "icmp";
        icmp_type = [
          "echo-request"
          "echo-reply"
          "destination-unreachable"
          "packet-too-big"
          "time-exceeded"
          "bad-header"
          "unknown-header-type"
          "router-solicitation"
          "neighbour-solicitation"
          "router-advertisement"
          "neighbour-advertisement"
        ];
        limit = "1000/sec";
        family = "ipv6";
        target = "ACCEPT";
      }
      {
        name = "Allow-ICMPv6-Forward";
        src = "wan";
        dest = "*";
        proto = "icmp";
        icmp_type = [
          "echo-request"
          "echo-reply"
          "destination-unreachable"
          "packet-too-big"
          "time-exceeded"
          "bad-header"
          "unknown-header-type"
        ];
        limit = "1000/sec";
        family = "ipv6";
        target = "ACCEPT";
      }
      {
        name = "Allow-IPSec-ESP";
        src = "wan";
        dest = "lan";
        proto = "esp";
        target = "ACCEPT";
      }
      {
        name = "Allow-ISAKMP";
        src = "wan";
        dest = "lan";
        dest_port = 500;
        proto = "udp";
        target = "ACCEPT";
      }
    ];
    # 443 can't be limited to cloudflare ranges: jellyfin's record is dns-only
    # (cloudflare's terms don't allow proxying video); nginx on the server only
    # answers for jellyfin there
    redirect = [
      {
        name = "jellyfin";
        src = "wan";
        src_dport = 443;
        dest = "lan";
        dest_ip = hosts.server.ip;
        dest_port = 446;
        proto = "tcp";
        target = "DNAT";
      }
      {
        name = "qbittorrent";
        src = "wan";
        src_dport = 6881;
        dest = "lan";
        dest_ip = hosts.server.ip;
        dest_port = 6881;
        proto = "tcp udp";
        target = "DNAT";
      }
    ];
  };
}
