{ lib, config, flake, pkgs, ... }:
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
    # TODO: fails for some reason
    systemd.services.NetworkManager-wait-online.enable = false;

    networking.wireless.enable = false;
    networking.networkmanager = {
      enable = true;

      dispatcherScripts = with pkgs; [{
        source = writeText "upHook" ''
          if [ "$1" = "hall" ]; then
            [ "$2" = "up" ] && setting=false
            ${sudo}/bin/sudo -u ${flake.lib.username} ${dbus}/bin/dbus-launch ${glib}/bin/gsettings set org.gnome.desktop.screensaver lock-enabled ''${setting:-true}
          fi
        '';
      }];

      ensureProfiles = {
        environmentFiles = [ config.age.secrets.wifi.path ];
        profiles.hall = {
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
}
