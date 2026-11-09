{ lib, network, ... }:
let
  inherit (network) hosts;
in
{
  uci.settings.dhcp = {
    dnsmasq = [
      {
        domainneeded = true;
        localise_queries = true;
        rebind_protection = true;
        rebind_localhost = true;
        local = "/lan/";
        domain = "lan";
        expandhosts = true;
        cachesize = 1000;
        authoritative = true;
        readethers = true;
        leasefile = "/tmp/dhcp.leases";
        resolvfile = "/tmp/resolv.conf.d/resolv.conf.auto";
        localservice = true;
        ednspacket_max = 1232;
        quietdhcp = true;
        # split DNS: most specific match wins
        address = [
          "/home.${network.domain}/${hosts.homeassistant.ip}"
          "/.${network.domain}/${hosts.server.ip}"
        ];
      }
    ];
    dhcp = {
      lan = {
        interface = "lan";
        start = 100;
        limit = 150;
        leasetime = "12h";
        dhcpv4 = "server";
        dhcpv6 = "server";
        ra = "server";
        ra_slaac = true;
        ra_flags = [
          "managed-config"
          "other-config"
        ];
      };
      wan = {
        interface = "wan";
        ignore = true;
      };
    };
    odhcpd.odhcpd = {
      leasefile = "/tmp/odhcpd.leases";
      leasetrigger = "/usr/sbin/odhcpd-update";
      loglevel = 4;
      piodir = "/tmp/odhcpd-piodir";
      hostsdir = "/tmp/hosts";
    };
    host = lib.mapAttrs (name: h: {
      inherit name;
      inherit (h) mac ip;
    }) (lib.filterAttrs (_: h: h ? mac) hosts);
  };
}
