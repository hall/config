{ lib, network, ... }:
let
  inherit (network) hosts;

  # DoH upstreams, tried in order. mullvad is the backup only because it
  # anycasts to singapore (~220ms) from here; quad9 is ~8ms
  upstreams = [
    {
      url = "https://dns.quad9.net/dns-query";
      bootstrap = "9.9.9.9,149.112.112.112";
      port = 5053;
    }
    {
      url = "https://dns.mullvad.net/dns-query";
      bootstrap = "194.242.2.2";
      port = 5054;
    }
  ];
in
{
  packages = [ "https-dns-proxy" ];

  uci.settings."https-dns-proxy" = {
    main.config = {
      # dewclaw owns the dhcp config and adblock already forces lan DNS
      dnsmasq_config_update = "-";
      force_dns = false;
      # the check resolves a third-party domain on every start
      heartbeat_domain = "-";
      notrack_dns = true;
      user = "nobody";
      group = "nogroup";
      listen_addr = "127.0.0.1";
      # no IPv6 from the ISP
      force_ip_family = "ipv4";
    };
    "https-dns-proxy" = map (u: {
      resolver_url = u.url;
      bootstrap_dns = u.bootstrap;
      listen_port = u.port;
    }) upstreams;
  };

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
        # only the DoH proxies, never the ISP-provided resolvers
        noresolv = true;
        strictorder = true;
        server = map (u: "127.0.0.1#${toString u.port}") upstreams;
        localservice = true;
        # don't bind the WAN address at all, rather than relying on the firewall
        notinterface = [ "wan" ];
        ednspacket_max = 1232;
        quietdhcp = true;
        address = [
          # split DNS: most specific match wins
          "/home.${network.domain}/${hosts.homeassistant.ip}"
          "/.${network.domain}/${hosts.server.ip}"
          # NXDOMAIN canaries: stop Firefox auto-enabling its own DoH and iCloud
          # Private Relay, either of which would bypass the router's DNS
          "/use-application-dns.net/"
          "/mask.icloud.com/"
          "/mask-h2.icloud.com/"
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
