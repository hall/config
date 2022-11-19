{ kubenix, flake, vars, lib, pkgs, ... }:
let
  hostname = "home.${flake.hostname}";
  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/home-automation/home-assistant.nix
  config = cfg: builtins.readFile (pkgs.runCommand "configuration.yaml" { preferLocalBuild = true; } ''
    cp ${(pkgs.formats.yaml {}).generate "configuration.yaml" (cfg)} $out
    sed -i -e "s/'\!\([a-z_]\+\) \(.*\)'/\!\1 \2/;s/^\!\!/\!/;" $out
  '');
in
{
  helm.releases.home-assistant = {
    chart = vars.template { inherit kubenix; };
    namespace = "default";
    values = {
      image = {
        repository = "homeassistant/home-assistant";
        tag = "2022.11";
      };
      service.main.ports.http.port = 8123;
      ingress.main = {
        enabled = true;
        hosts = [{
          host = hostname;
          paths = [{ path = "/"; }];
        }];
      };
      persistence = {
        config = {
          enabled = true;
          mountPath = "/config";
          storageClass = "longhorn-static";
        };
        configuration = {
          enabled = true;
          type = "configMap";
          subPath = "config.yaml";
          mountPath = "/config/configuration.yaml";
          name = "home-assistant-config";
          readOnly = true;
        };
        floorplan = {
          enabled = true;
          type = "configMap";
          mountPath = "/config/www/floorplan";
          name = "home-assistant-floorplan";
          readOnly = true;
        };
        www = {
          enabled = true;
          type = "configMap";
          mountPath = "/config/www/sidebar-order.yaml";
          subPath = "sidebar-order.yaml";
          name = "home-assistant-www";
          readOnly = true;
        };
        dashboards = {
          enabled = true;
          type = "configMap";
          mountPath = "/config/dashboards";
          name = "home-assistant-dashboards";
          readOnly = true;
        };
        lovelace = {
          enabled = true;
          type = "configMap";
          mountPath = "/config/ui-lovelace.yaml";
          subPath = "lovelace.yaml";
          name = "home-assistant-lovelace";
          readOnly = true;
        };
        secrets = {
          enabled = true;
          type = "secret";
          subPath = "secrets.yaml";
          mountPath = "/config/secrets.yaml";
          name = "home-assistant";
          readOnly = true;
        };
      };
      secret."secrets.yaml" = vars.secret "/home";

      # hacs:
      #   integrations:
      #     circadian lighting
      #     frigate
      #     dahua vto
      #     browser mod # TODO: not using?
      #   frontend:
      #     nord theme
      #     ha floorplan
      #     custom sidebar
      #   automations:
      #     shellies discovery
      #
      #
      #   landroid-cloud
      #   hifiberry
      #   petkit?

      configmap = {
        www = {
          enabled = true;
          data."sidebar-order.yaml" = config {
            order = [
              { item = "overview"; }
              { item = "browser"; hide = true; }
              { item = "media"; }
              { item = "docs"; }
              { item = "photos"; }
              { item = "grocy"; }
              { item = "security"; }
              { item = "admin"; bottom = true; }
              { item = "hacs"; bottom = true; }
              { item = "map"; hide = true; }
              { item = "logbook"; bottom = true; }
              { item = "history"; bottom = true; }
            ];
          };
        };
        floorplan = {
          enabled = true;
          data = {
            "config.yaml" = config (import ./floorplan);
            "blueprint.svg" = builtins.readFile ./floorplan/blueprint.svg;
            "style.css" = builtins.readFile ./floorplan/style.css;
          };
        };
        dashboards = {
          enabled = true;
          data = {
            "admin.yaml" = config (import ./dashboards/admin.nix { inherit lib flake; });
          };
        };
        lovelace = {
          enabled = true;
          data = {
            "lovelace.yaml" = config (import ./dashboards/lovelace.nix);
          };
        };
        config = {
          enabled = true;
          data."config.yaml" = config
            {
              homeassistant = {
                name = "Home";
                latitude = "!secret latitude";
                longitude = "!secret longitude";
                #elevation:
                unit_system = "metric";
                time_zone = "!secret timezone";
                external_url = "https://${hostname}";
                internal_url = "https://${hostname}";

                auth_providers = [{
                  type = "trusted_networks";
                  trusted_networks = [
                    "192.168.1.0/24"
                    "10.42.0.0/16"
                    "fd00::/8"
                    "10.0.0.0/8"
                  ];
                  allow_bypass_login = true;
                }
                  { type = "homeassistant"; }];
              };
              http = {
                use_x_forwarded_for = true;
                trusted_proxies = [
                  "10.0.0.0/8"
                  "10.42.0.0/16"
                  "127.0.0.0/8"
                ];
              };

              #media_source = {};
              #logger.default= "debug";
              weather = { };
              sun = { };
              config = { };
              history = { };
              logbook = { };
              stream = { };
              updater = { };
              map = { };
              mobile_app = { };
              discovery = { };
              system_health = { };
              prometheus = { };
              #transmission = {
              #  host = "https://downloads.${flake.hostname}/transmission/rpc";
              #  port = 443;
              # };
              python_script = { };
              recorder.db_url = "!secret postgresql";

              automation = import ./automations.nix { };

              # script = {
              #   printer = {
              #     printer_home.sequence = [{
              #       service = "mqtt.publish";
              #       data = {
              #         topic = "octoPrint/hassControl/home";
              #         payload = ''["x", "y", "z"]'';
              #       };
              #     }];
              #   };
              # };


              frontend = {
                # the `themes` directory is managed by HACS
                themes = "!include_dir_merge_named themes";
                extra_module_url = [
                  "/hacsfiles/custom-sidebar/custom-sidebar.js"
                  # "/hacsfiles/stack-in-card/stack-in-card.js"
                  # "/hacsfiles/mini-graph-card/mini-graph-card-bundle.js"
                  # "/hacsfiles/bar-card/bar-card.js"
                  # "/hacsfiles/lovelace-card-templater/lovelace-card-templater.js"
                ];
              };


              lovelace = {
                mode = "yaml";
                resources = [
                  {
                    url = "/hacsfiles/ha-floorplan/floorplan.js";
                    type = "module";
                  }
                ];
                dashboards = {
                  # lovelace-media = {
                  #   mode = "yaml";
                  #   filename = "dashboards/media.yaml";
                  #   title = "Media";
                  #   icon = "mdi:bookshelf";
                  # };
                  lovelace-admin = {
                    mode = "yaml";
                    filename = "dashboards/admin.yaml";
                    title = "Admin";
                    icon = "mdi:console-line";
                  };
                };
              };

              #telegram-bot

              matrix = {
                homeserver = "https://matrix.org";
                username = "!secret matrix_user";
                password = "!secret matrix_pass";
                rooms = [ "!secret matrix_room" ];
                commands = [{
                  name = "theme";
                  word = "theme";
                }];
              };

              notify = [
                {
                  name = "phones";
                  platform = "group";
                  services = [
                    { service = "mobile_app_sm_n950u1"; }
                    { service = "mobile_app_sm_g965u1"; }
                  ];
                }
                {
                  name = "matrix";
                  platform = "matrix";
                  default_room = "!secret matrix_room";
                }
                {
                  name = "tv";
                  platform = "kodi";
                  host = "tv";
                  username = "kodi";
                  password = "!secret kodi";
                }
                # {
                #   name = "gotify";
                #   platform = "rest";
                #   resource = "http://gotify/message";
                #   method = "POST_JSON";
                #   headers.X-Gotify-Key = "!secret gotify_key";
                #   message_param_name = "message";
                #   title_param_name = "title";
                #   data.extras."client::display".contentType = "text/markdown";
                # }
              ];

              person = [
                {
                  name = "Bryton";
                  id = "bryton";
                  device_trackers = [ "device_tracker.sm_n950u1" ];
                }
                {
                  name = "Kristin";
                  id = "kristin";
                  device_trackers = [ "device_tracker.sm_g965u1" ];
                }
              ];
              # device_tracker = [{
              #   platform = "luci";
              #   host = "router.lan";
              #   username = "root";
              #   password = "!secret router";
              #   ssl = true;
              #   verify_ssl = false;
              # }];
              # media_player = [{
              #   platform = "emby";
              #   host = "player.${flake.hostname}";
              #   api_key = "!secret jellyfin";
              #   ssl = true;
              #   port = 443;
              # }];
              # roomba = [{
              #   host = "vacuum";
              #   # continuous = false;
              #   blid = "!secret roomba_user";
              #   password = "!secret roomba_pass";
              # }];

              #mycroft.host= "picroft.lan";

              panel_iframe = {
                docs = {
                  title = "Docs";
                  icon = "mdi:file-document";
                  url = "https://docs.${flake.hostname}";
                };
                photos = {
                  title = "Photos";
                  icon = "mdi:image";
                  url = "https://photos.${flake.hostname}";
                };
                security = {
                  title = "Security";
                  icon = "mdi:security";
                  url = "https://frigate.${flake.hostname}";
                };
              };

              # adaptive_lighting https://github.com/basnijholt/adaptive-lighting/issues/85
              circadian_lighting = { };

              switch = [{
                platform = "circadian_lighting";
                lights_rgb = [ "light.lights" ];
                #prefer_rgb_color: true
                #min_color_temp: 1000
              }];

              light = [
                {
                  platform = "group";
                  name = "lights";
                  entities = [
                    "light.office"
                    "light.livingroom"
                    "light.bedroom"
                  ];
                }
                {
                  platform = "group";
                  name = "livingroom";
                  entities = [
                    "light.livingroom_light"
                  ];
                }
                {
                  platform = "group";
                  name = "bedroom";
                  entities = [
                    "light.bedroom_light"
                    "light.unassigned_light"
                  ];
                }
                {
                  platform = "group";
                  name = "office";
                  entities = [ "light.office_light" ];
                }
              ];

              sensor = [
                # {
                #   platform = "dahua_vto";
                #   name = "doorbell";
                #   host = "doorbell";
                #   username = "admin";
                #   password = "!secret doorbell";
                # }
                {
                  platform = "worxlandroid";
                  host = "robotic-mower";
                  pin = "!secret landroid";
                }
              ];

              alarm_control_panel = [{
                platform = "manual";
                name = "home";
              }];

            };
        };
      };
    };
  };
}
