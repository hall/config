{ flake, ... }:
let
  ssid = "hall";
in
{
  environment = {
    etc = {
      wifi = {
        target = "NetworkManager/system-connections/${ssid}.nmconnection";
        mode = "0400";
        text = ''
          [connection]
          id=${ssid}
          type=wifi

          [wifi]
          ssid=${ssid}

          [wifi-security]
          key-mgmt=wpa-psk
          psk=${flake.lib.pass "wifi"}
        '';
      };
    };
  };
}
