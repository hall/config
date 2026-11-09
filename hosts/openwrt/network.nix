# facts shared across devices
#
# TODO: move the VLAN plan from docs/network-architecture.md here and derive
# router interfaces/zones, switch port maps, and AP SSID bridges from it
{
  domain = "bryton.io";
  lan = {
    address = "192.168.1.1";
    prefix = 24;
  };
  ssid = "hall";
  hosts = {
    switch = {
      mac = "0c:0e:76:74:3e:c0";
      ip = "192.168.1.2";
    };
    ap1 = {
      mac = "80:af:ca:2b:b6:94";
      ip = "192.168.1.3";
    };
    ap2 = {
      mac = "80:af:ca:f2:1e:9a";
      ip = "192.168.1.4";
    };
    server = {
      mac = "88:AE:DD:05:C9:46";
      ip = "192.168.1.5";
    };
    homeassistant.ip = "192.168.1.10";
  };
}
