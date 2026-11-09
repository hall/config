# D-Link DGS-1210-28MP F (realtek/rtl838x)
{ lib, ... }:
let
  ports = map (i: "lan${toString i}") (lib.range 1 28);
  # PoE controller ids run 1..24 over lan8..lan1, lan16..lan9, lan24..lan17
  poePorts = lib.concatMap (bank: lib.reverseList (lib.range (bank * 8 + 1) (bank * 8 + 8))) [
    0
    1
    2
  ];
in
{
  packages = [
    "ethtool"
    "realtek-poe"
  ];

  # sysupgrade refuses images whose compat_version doesn't match
  system.compat_version = "1.0";

  # a reboot cuts PoE to the APs, so a deployer on wifi only reconnects after they boot too
  deploy = {
    rebootAllowance = 180;
    rollbackTimeout = 300;
  };

  # unused defaults; the switch doesn't route
  uci.retain = [ "firewall" ];

  uci.settings = {

    network = {
      globals.globals = {
        dhcp_default_duid = "000495aa69bc7549402b8abee1c50dfe552c";
        ula_prefix = "fda5:cc66:e446::/48";
        packet_steering = true;
      };
      device = {
        switch = {
          name = "switch";
          type = "bridge";
          macaddr = "0c:0e:76:74:3e:c0";
        };
        switch_1 = {
          name = "switch.1";
          macaddr = "0c:0e:76:74:3e:c0";
        };
      };
      # TODO: per-VLAN bridge-vlan sections with tagged (`lanN:t`) trunk ports
      bridge-vlan.lan_vlan = {
        device = "switch";
        vlan = 1;
        # a string, as LuCI writes it, so the first deploy is a no-op for netifd
        ports = lib.concatStringsSep " " ports;
      };
      interface.lan = {
        device = "switch.1";
        proto = "dhcp";
      };
    };

    poe = {
      global = [ { budget = 370; } ];
      port = lib.imap1 (id: n: {
        name = "lan${toString n}";
        inherit id;
        enable = true;
      }) poePorts;
    };
  };
}
