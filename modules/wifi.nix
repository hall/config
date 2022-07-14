{ lib, config, flake, ... }:
with lib;
let
  name = "wifi";
  cfg = config.services.${name};
in
{
  options.services.${name} = {
    enable = mkEnableOption "wifi";
    ssid = mkOption {
      type = types.str;
      default = "hall";
    };
  };

  config = mkIf cfg.enable {
    environment = {
      etc = {
        wifi = {
          target = "NetworkManager/system-connections/${cfg.ssid}.nmconnection";
          mode = "0400";
          text = ''
            [connection]
            id=${cfg.ssid}
            type=wifi

            [wifi]
            ssid=${cfg.ssid}

            [wifi-security]
            key-mgmt=wpa-psk
            psk=${flake.lib.pass {name = "wifi";}}
          '';
        };
      };
    };
  };
}
