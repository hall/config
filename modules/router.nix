# todo
# 
# - ap: <https://github.com/mausch/nixos-configuration/blob/master/wifi-access-point.nix>
# - dhcp
# - dns
# - wg
# - fw

{ config, lib, pkgs, flake, ... }:
let
  name = "router";
  cfg = config.${name};
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
  };
  config = lib.mkIf cfg.enable {

    networking = {
      interfaces = {
        "${cfg.external}".useDHCP = true;
        "${cfg.internal}" = {
          useDHCP = false;
          ipv4.addresses = [{
            address = "10.0.0.1";
            prefixLength = 24;
          }];
        };
      };

      nat = {
        enable = true;
        externalInterface = cfg.external;
        internalInterfaces = [ cfg.internal ];
        internalIPs = [ "10.0.0.0/24" ];
      };

      firewall = {
        allowedTCPPorts = [
          53 # dns
        ];
        allowedUDPPorts = [
          53 # dns
          67 # dhcp
        ];
        trustedInterfaces = [ cfg.internal ];
      };

      networkmanager.enable = lib.mkForce false;
      nameservers = [ "8.8.8.8" "1.1.1.1" ];
      enableIPv6 = false;
    };

    # enable Kernel IP Forwarding (aka, routing)
    # https://unix.stackexchange.com/questions/14056/what-is-kernel-ip-forwarding
    boot.kernel.sysctl = {
      "net.ipv4.conf.all.forwarding" = true;
      "net.ipv4.conf.default.forwarding" = true;
    };

    services = {
      dhcpd4 = {
        enable = true;
        interfaces = [ cfg.internal ];
        machines = [
          # {
          #   ethernetAddress = "";
          #   hostName = "switch";
          #   ipAddress = "10.0.0.2";
          # }
          # {
          #   ethernetAddress = "24:52:6A:9F:02:DE";
          #   hostName = "doorbell";
          #   ipAddress = "10.0.0.20";
          # }
        ];
      };

      dnsmasq = {
        # enable = true;
        servers = [
          "8.8.8.8"
          "8.8.4.4"
        ];
        extraConfig =
          # lb is running on self
          "address=/.${flake.hostname}/10.0.0.1"
        ;
      };


      # speed/bandwidth testing
      iperf3 = {
        enable = true;
        openFirewall = true;
      };
    };

    # utils
    environment.systemPackages = with pkgs; [
      tcpdump
      ethtool
    ];
  };
}
