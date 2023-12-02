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
    networking.networkmanager = {
      enable = true;
      ensureProfiles = {
        environmentFiles = [ config.age.secrets.wifi.path ];
        profiles = {
          hall = {
            connection = {
              id = "hall";
              type = "wifi";
            };
            ipv4 = {
              method = "auto";
            };
            ipv6 = {
              addr-gen-mode = "stable-privacy";
              method = "auto";
            };
            wifi = {
              mode = "infrastructure";
              ssid = "hall";
            };
            wifi-security = {
              auth-alg = "open";
              key-mgmt = "wpa-psk";
              psk = "$PSK";
            };
          };
        };
      };
    };
  };
}
