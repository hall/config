{ config, lib, pkgs, flake, ... }:
let
  name = "router";
  cfg = config.${name};
  prefix = "10.0.0";
in
{
  options.${name} = {
    enable = lib.mkEnableOption "run network services";
    internal = lib.mkOption {
      description = "internal interface name";
      type = lib.types.str;
    };
    external = lib.mkOption {
      description = "external interface name";
      type = lib.types.str;
    };
    wireless = lib.mkOption {
      description = "wireless interface name";
      type = lib.types.str;
    };
  };
  config = lib.mkIf cfg.enable {

    networking = {
      enableIPv6 = false;

      interfaces = {
        "${cfg.internal}" = {
          ipv4.addresses = [{
            address = "${prefix}.1";
            prefixLength = 24;
          }];
        };
      };

      nameservers = [ "8.8.8.8" "8.8.4.4" ];

      nat = {
        enable = true;
        externalInterface = cfg.external;
        internalInterfaces = with cfg; [ internal ];
        internalIPs = [ "${prefix}.0/24" ];
      };

      firewall.interfaces.${cfg.internal}.allowedUDPPorts = [
        53 # dns
        67 # dhcp
      ];

      # firewall
      # nftables = {
      #   enable = false;
      #   ruleset = ''
      #     table ip filter {
      #       # chain output {
      #       #   type filter hook output priority 100; policy accept;
      #       # }

      #       chain input {
      #         type filter hook input priority filter; policy drop;

      #         iifname { "${cfg.internal}" } counter accept comment "allow local network"
      #         iifname "${cfg.external}" ct state { established , related } counter accept comment "allow established traffic"
      #         iifname "${cfg.external}" icmp type { echo-request, destination-unreachable, time-exceeded } counter accept
      #         iifname "${cfg.external}" drop comment "drop all other from wan"
      #       }

      #       chain forward {
      #         type filter hook forward priority filter; policy drop;
      #         iifname { "${cfg.internal}" } oifname { "${cfg.external}" } counter accept comment "allow trusted lan to wan"
      #         iifname { "${cfg.external}" } oifname { "${cfg.internal}" } ct state { established, related } counter accept comment "allow established back to lan"
      #       }

      #     }

      #     table ip nat {
      #       chain prerouting {
      #         type nat hook output priority filter; policy accept;
      #       }
      #       chain postrouting {
      #         type nat hook postrouting priority filter; policy accept;
      #         oifname "${cfg.external}" masquerade
      #       }
      #     }
      #   '';
      # };

    };

    services = {
      # dns, dhcp
      dnsmasq = {
        enable = true;
        servers = [ "8.8.8.8" "8.8.4.4" ];
        resolveLocalQueries = false;
        extraConfig = ''
          domain-needed  # don't forward plain names
          bogus-priv     # don't forward unroutable addresses
          no-resolv      # use dnsmasq exclusively
          no-hosts       # ignore /etc/hosts

          interface=${cfg.internal}
          address=/${config.networking.hostName}/${prefix}.1

          dhcp-authoritative
          dhcp-range=${prefix}.100,${prefix}.254,12h
          #dhcp-host=11:22:33:44:55:66,192.168.0.60
        '';
      };

      # TODO: vpn
      # headscale = {
      #   enable = true;
      # };


      # TODO: ap: <https://github.com/mausch/nixos-configuration/blob/master/wifi-access-point.nix>
      # hostapd = {
      #   enable = true;
      # };


      # speed/bandwidth testing
      # iperf3 = {
      #   enable = true;
      #   openFirewall = true;
      # };
    };

    environment.systemPackages = with pkgs; [
      tcpdump
      ethtool
      conntrack-tools
      inetutils
      pciutils
      bind
    ];
  };
}
