{ flake, lib, ... }: {
  services = {
    home-assistant = {
      enable = true;
      extraComponents = [
        "esphome"
        "met"
        "radio_browser"
        "isal"
      ];
      extraPackages = python3Packages: with python3Packages; [
        # recorder postgresql support
        psycopg2
        pychromecast
        python-otbr-api
        gtts
        roombapy
        ibeacon-ble
        aiogithubapi
      ];
      # `/var/lib` is harder to write to declaratively :/
      configDir = "/etc/home-assistant";
      config = {
        # https://www.home-assistant.io/integrations/default_config/
        default_config = { };
        recorder.db_url = "postgresql://@/hass";
        http = {
          server_host = "::1";
          trusted_proxies = [ "::1" ];
          use_x_forwarded_for = true;
        };
        homeassistant = {
          unit_system = "metric";
          temperature_unit = "C";
          # longitude = 0;
          # latitude = 0;
        };
        lovelace = {
          mode = "yaml";
          dashboards.lovelace-media = {
            mode = "yaml";
            filename = "dashboards/media.yaml";
            title = "Media";
            icon = "mdi:bookshelf";
          };
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

  # this thing tries to symlink to `/etc/home-assistant`
  systemd.services.home-assistant.preStart = lib.mkForce "";

  environment.etc = lib.mapAttrs' (name: value: lib.nameValuePair "home-assistant/${name}" value) {
    # remove redundant logging https://community.home-assistant.io/t/disable-logging-to-file/79496
    "home-assistant.log".source = "/dev/null";
    "dashboards/media.yaml".text = builtins.toJSON {
      views = builtins.map
        (view: {
          title = view;
          path = view;
          panel = true;
          cards = [{
            type = "iframe";
            url = "https://${view}.${flake.lib.hostname}";
          }];
        }) [ "player" "requests" "downloads" "movies" "shows" "music" "indexer" ];
    };
    "www/sidebar-config.json".text = builtins.toJSON {
      sidebar_editable = false;
      order = [
        { item = "overview"; }
        { item = "energy"; }
        { item = "to-do lists"; }
        { item = "hacs"; bottom = true; }
        { item = "map"; bottom = true; }
        { item = "developer tools"; bottom = true; }
        { item = "settings"; bottom = true; }
        { item = "media-browser"; hide = true; }
        { item = "logbook"; hide = true; }
        { item = "history"; hide = true; }
      ];
    };
  };
}
