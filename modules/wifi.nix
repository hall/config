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
      enable = true;
      environmentFile = "/run/secrets/wifi";
      networks.${cfg.ssid}.psk = "@PSK@";
    };
  };
}
