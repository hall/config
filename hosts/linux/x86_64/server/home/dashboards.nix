{ flake, lib, ... }: {
  services.home-assistant.config.lovelace = {
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

  environment.etc = lib.mapAttrs' (name: value: lib.nameValuePair "home-assistant/${name}" value) {
    "ui-lovelace.yaml".text = builtins.toJSON {
      title = "Home";
      views = [{
        path = "default_view";
        title = "Home";
        # badges = [
        #   {
        #     entity = "switch.circadian_lighting_circadian_lighting";
        #     name = "Circadian";
        #     tap_action.action = "toggle";
        #     hold_action.action = "more-info";
        #   }
        #   # { entity = "alarm_control_panel.home"; }
        #   # { entity = "weather.home"; }
        # ];
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
        }) [ "esphome" "zigbee" "music-assistant" "grafana" ];
    };
  };
}
