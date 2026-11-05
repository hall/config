{
  lib,
  config,
  ...
}:
with lib;
let
  name = "wifi";
  cfg = config.services.${name};
  envFile = "/run/wifi-psk.env";
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
    # TODO: https://github.com/NixOS/nixpkgs/issues/180175
    systemd.services.NetworkManager-wait-online.enable = false;

    # Generate PSK= prefixed env file from raw password
    systemd.services.wifi-env = {
      description = "Generate WiFi PSK environment file";
      wantedBy = [ "NetworkManager.service" ];
      before = [ "NetworkManager.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        umask 077
        echo "PSK=$(cat ${config.age.secrets.wifi.path})" > ${envFile}
      '';
    };

    networking.networkmanager = {
      enable = true;

      ensureProfiles = {
        environmentFiles = [ envFile ];
        profiles.${cfg.ssid} = {
          connection = {
            id = cfg.ssid;
            type = "wifi";
          };
          ipv4.method = "auto";
          ipv6 = {
            addr-gen-mode = "stable-privacy";
            method = "auto";
          };
          wifi = {
            mode = "infrastructure";
            inherit (cfg) ssid;
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
}
