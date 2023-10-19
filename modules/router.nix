{ config, lib, pkgs, flake, ... }:
let
  name = "router";
  cfg = config.${name};
  prefix = "10.0.0";
  gateway = "${prefix}.1";
  mask = 24;
  lb_ports = [
    443 # svc
    6443 # k8s
    1883 # mqtt
    465 # smtp
    993 # imap
  ];
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

      interfaces = {
        "${cfg.external}" = { };
        "${cfg.internal}" = {
          ipv4.addresses = [{
            address = gateway;
            prefixLength = mask;
          }];
        };
      };

      nameservers = [ "8.8.8.8" "8.8.4.4" ];

      nat = {
        enable = true;
        externalInterface = cfg.external;
        internalInterfaces = [ cfg.internal ];
        internalIPs = [ "${prefix}.0/${builtins.toString mask}" ];
      };

      firewall =
        let
          internal = {
            allowedTCPPorts = [
              22 # ssh
              80 # http redirect
              9100 # prometheus
            ] ++ lb_ports;
            allowedUDPPorts = [
              53 # dns
              67 # dhcp
            ];
          };
        in
        {
          # don't allow anything by default
          allowedTCPPorts = lib.mkForce [ ];
          allowedUDPPorts = lib.mkForce [ ];
          interfaces = {
            ${cfg.internal} = internal;
          };
        };

    };

    age.secrets.wg.file = ../secrets/wg_${config.networking.hostName}.age;

    services = {
      # dns, dhcp
      dnsmasq = {
        enable = true;
        settings = {
          server = [ "10.0.0.1" "8.8.8.8" "8.8.4.4" ];
          domain-needed = true; # don't forward plain names
          bogus-priv = true; # don't forward unroutable addresses
          # no-resolv = true; # use dnsmasq exclusively
          no-hosts = true; # ignore /etc/hosts
          interface = [ cfg.internal wgInternal ];
          address = [
            "/${config.networking.hostName}/${gateway}"
            "/${flake.lib.hostname}/${gateway}" # k8s svc
            "/k/${gateway}" # k8s api
            "/doorbell/${prefix}.10" # not dhcp capable
          ];
          cname = [
            "registry,tv" # docker registry TODO: don't hardcode hostname
          ];

          dhcp-authoritative = true;
          dhcp-range = [ "${prefix}.100,${prefix}.254,12h" ];
          dhcp-host = [
            "88:15:44:60:14:88,switch" # switch fails to set its own hostname
            "50:14:79:36:c0:0b,vacuum" # cannot set roomba's hostname
          ];
        };
      };

      # k8s api lb
      nginx = {
        enable = true;
        config = ''
          events {
            worker_connections 1024;
          }
          http {
            server {
              listen 80;
              return 301 https://$host$request_uri;
            }
          }
          stream {
            ${builtins.toString (map (p: ''
            server {
              listen ${p};
              proxy_pass ${p};
            }

            upstream ${p} {
              server k0:${p} max_fails=6 fail_timeout=30s;
              server k1:${p} max_fails=6 fail_timeout=30s;
              server k2:${p} max_fails=6 fail_timeout=30s;
            }
            '') (map (p: builtins.toString p) lb_ports) )}
          }
        '';
      };

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

    systemd.services.nginx = {
      # wait for dns
      after = [ "network-online.target" "dnsmasq.service" ];
      wants = [ "network-online.target" "dnsmasq.service" ];
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
