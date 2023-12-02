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
    age.secrets.wifi.rekeyFile = ./wifi.age;
    networking.wireless = {
      enable = true;
      environmentFile = config.age.secrets.wifi.path;
      networks.${cfg.ssid}.psk = "@PSK@";
    };
  };
}
