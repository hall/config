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
    age.secrets.wifi.file = ../secrets/wifi.age;
    networking.wireless = {
      environmentFile = "/run/secrets/wifi";
      enable = true;
      networks.${cfg.ssid}.psk = "@WIFI_PSK@";
    };
  };
}
