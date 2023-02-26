{ ... }: {
  image = "/local/floorplan/blueprint.svg";
  stylesheet = "/local/floorplan/style.css";
  #log_level= info
  #console_log_level= info
  defaults = {
    hover_action = "hover-info";
    hold_action = "toggle";
    tap_action = "more-info";
  };
  rules = [
    # TODO: ideas
    # - current, power
    # - pressure, gas (BME680)
    # - co2, voc (ccs811)
    # - particulate matter (HM3301)
    # - magnetometer?
    # - water flow
    # - wind speed/direction

    # doors
    # windows
    {
      entities = [
        "climate.thermostat"
        "cover.garage_door"
        "media_player.kodi"
        "camera.front_yard"
        "camera.back_yard"
        "camera.doorbell"
        "binary_sensor.washing_machine_flood"
        "binary_sensor.water_heater_flood"
      ];
    }

    {
      # inverse: tap to toggle
      entities = [
        "switch.printer_power_relay"
        "switch.christmas_tree_power_relay"
      ];
      tap_action = "toggle";
      hold_action = "more-info";
    }

    {
      entities = [ "vacuum.roomba" ];
      state_action = [{
        action = "call-service";
        service = "floorplan.class_set";
        service_data = ''
          >
          var color = 'black'

          if (entities["binary_sensor.roomba_bin_full"].state === 'on') {
              return 'error'
          else if (entities["binary_sensor.roomba_battery_level"].state < 30) {
              return 'warning'
          }

          return 'normal'
        '';
      }];
    }

    {
      ###
      # text
      ###
      entities = [
        "sensor.office_temperature"
        "sensor.office_humidity"
        "sensor.attic_temperature"
        "sensor.attic_humidity"
      ];
      state_action = {
        action = "call-service";
        service = "floorplan.text_set";
        service_data = "\${entity.state} \${entity.attributes.unit_of_measurement}";
      };
    }

    {
      ###
      # lights
      ###
      entities = [
        "light.office"
        "light.office_light_switch"
        "light.bedroom"
        "light.bedroom_light_switch"
        "light.nightstand_light_left"
        "light.nightstand_light_right"
        "light.livingroom"
        "light.livingroom_light_switch"
        "light.guest_light_switch"
      ];
      tap_action = "toggle";
      hold_action = "more-info";
      state_action = [{
        action = "call-service";
        service = "floorplan.style_set";
        service_data = ''
          var color = 'black'

          if (entity.state === 'on') {
            var rgb = [255,255,255]; 
            if (entity.attributes.rgb_color) {
              rgb = entity.attributes.rgb_color
            }
            else if (entity.attributes.color_temp) {
              rgb = util.color.miredToRGB(entity.attributes.color_temp)
            }
              color = `rgb($${rgb[0]}, $${rgb[1]}, $${rgb[2]})`
          }

          return `fill=$${color};`
        '';
      }];
    }
  ];
}
