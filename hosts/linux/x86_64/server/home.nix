{ flake, pkgs, ... }: {

  services = {
    home-assistant = {
      enable = true;
      extraComponents = [
        # Components required to complete the onboarding
        "esphome"
        "met"
        "radio_browser"
      ];
      extraPackages = python3Packages: with python3Packages; [
        # recorder postgresql support
        psycopg2
        pychromecast
        python-otbr-api
        gtts
        roombapy
      ];
      config = {
        # https://www.home-assistant.io/integrations/default_config/
        default_config = { };
        recorder.db_url = "postgresql://@/hass";
        http = {
          server_host = "::1";
          trusted_proxies = [ "::1" ];
          use_x_forwarded_for = true;
        };
      };
    };

    nginx.virtualHosts."home.${flake.lib.hostname}" = {
      useACMEHost = flake.lib.hostname;
      acmeRoot = null;
      forceSSL = true;
      extraConfig = ''
        proxy_buffering off;
      '';
      locations."/" = {
        proxyPass = "http://[::1]:8123";
        proxyWebsockets = true;
      };
    };

    postgresql = {
      enable = true;
      ensureDatabases = [ "hass" ];
      ensureUsers = [{
        name = "hass";
        ensureDBOwnership = true;
      }];
    };

  };
}
