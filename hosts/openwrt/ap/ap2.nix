# Cudy AP3000 Outdoor v1
_: {
  imports = [ ./default.nix ];

  uci.settings = {
    network.globals.globals = {
      dhcp_default_duid = "00042fabc7a4ff5a4fbe918839b51ddda660";
      ula_prefix = "fd57:efe8:d4dc::/48";
    };

    wireless.wifi-device = {
      radio0.channel = 1;
      radio1.channel = 36;
    };
  };
}
