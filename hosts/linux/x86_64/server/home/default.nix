{ flake, lib, ... }: {
  imports = with builtins; (map (v: ./${v})
    (filter (v: v != "default.nix")
      (attrNames (readDir ./.))));

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
        aiogithubapi
        androidtvremote2
        brother
        govee-ble
        gtts
        ibeacon-ble
        ical
        psycopg2
        pychromecast
        pyipp
        pyschlage
        python-otbr-api
        roombapy
        venstarcolortouch
        zeroconf
      ];
      # `/var/lib` is harder to write to declaratively :/
      configDir = "/etc/home-assistant";
      config = {
        # https://www.home-assistant.io/integrations/default_config/
        default_config = { };
        zeroconf = { };
        http = {
          server_host = "::1";
          trusted_proxies = [ "::1" ];
          use_x_forwarded_for = true;
        };
        prometheus = { };
        homeassistant = {
          external_url = "https://home.${flake.lib.hostname}";
          # TODO: be less imperial swine :)
          # unit_system = "metric";
          # temperature_unit = "C";
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
          dashboards.lovelace-admin = {
            mode = "yaml";
            filename = "dashboards/admin.yaml";
            title = "Admin";
            icon = "mdi:tune";
          };
        };
        frontend.themes = "!include_dir_merge_named themes";
        sensor = {
          platform = "worxlandroid";
          host = "robotic-mower";
          pin = "0121";
        };
        notify = [{
          platform = "group";
          name = "phones";
          services = [
            { action = "mobile_app_phone"; }
            { action = "mobile_app_pixel_8_pro"; }
          ];
        }];
        "automation ui" = "!include automations.yaml";
        "automation manual" = [
          {
            alias = "notify of new media";
            trigger = [{
              platform = "webhook";
              webhook_id = "media";
              allowed_methods = [ "POST" ];
              local_only = true;
            }];
            action = [{
              service = "notify.phones";
              data = {
                title = "{{ trigger.json.title }}";
                message = "{{ trigger.json.message }}";
              };
            }];
          }
          {
            alias = "vacuum schedule";
            mode = "single";
            triggers = [{
              trigger = "time";
              at = "10:00";
            }];
            conditions = [{
              condition = "time";
              weekday = [ "mon" "thu" ];
            }];
            actions = [{
              action = "vacuum.start";
              target.entity_id = "vacuum.roomba";
            }];
          }
          {
            alias = "set default theme";
            trigger = {
              platform = "homeassistant";
              event = "start";
            };
            action = {
              service = "frontend.set_theme";
              data.name = "midnight";
            };
          }
        ];
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

  };

  # this thing tries to symlink to `/etc/home-assistant`
  systemd.services.home-assistant.preStart = lib.mkForce "";

  # remove redundant logging https://community.home-assistant.io/t/disable-logging-to-file/79496
  system.activationScripts.home-assistant-disable-logging = ''
    ln -sf /dev/null /etc/home-assistant/home-assistant.log
  '';

  environment.etc = lib.mapAttrs' (name: value: lib.nameValuePair "home-assistant/${name}" value) {
    "ui-lovelace.yaml".text = builtins.toJSON {
      title = "Home";
      views = [{
        path = "default_view";
        title = "Home";
        badges = [
          {
            entity = "switch.circadian_lighting_circadian_lighting";
            name = "Circadian";
            tap_action.action = "toggle";
            hold_action.action = "more-info";
          }
          # { entity = "alarm_control_panel.home"; }
          # { entity = "weather.home"; }
        ];
        cards = [{
          type = "custom:floorplan-card";
          config = "/local/floorplan/config.yaml";
          full_height = true;
        }];
      }];
    };
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
        }) [ "player" "requests" "downloads" "movies" "shows" "music" "books" "indexer" ];
    };
    "dashboards/admin.yaml".text = builtins.toJSON {
      views = builtins.map
        (view: {
          title = view;
          path = view;
          panel = true;
          cards = [{
            type = "iframe";
            url = "https://${view}.${flake.lib.hostname}";
          }];
        }) [ "esphome" "zigbee" ];
    };
  };
}
