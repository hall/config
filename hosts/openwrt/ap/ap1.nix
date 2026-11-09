# Cudy AP3000 v1
{ lib, ... }:
{
  imports = [ ./default.nix ];

  uci.settings = {
    network.globals.globals = {
      dhcp_default_duid = "000474ac3d9d04db45b29483c612287d077e";
      ula_prefix = "fd7c:f7d6:e7fb::/48";
    };

    # indoors, so all LEDs off
    system.led =
      lib.mapAttrs
        (_: sysfs: {
          inherit sysfs;
          trigger = "none";
          default = false;
        })
        {
          wlan_5g = "blue:wlan-5ghz";
          wlan_2g = "red:wlan-2ghz";
          status = "amber:status";
          phy0 = "mt76-phy0";
          phy1 = "mt76-phy1";
        };
  };
}
