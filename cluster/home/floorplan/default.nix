{
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
        "printer.ender"
        "camera.front_yard"
        "camera.back_yard"
        "camera.doorbell"
        "binary_sensor.washing_machine_flood"
        "binary_sensor.water_heater_flood"
      ];
    }

    {
      entities = [
        "vacuum.roomba"
      ];
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
        #- sensor.living_room_temperature
        #- sensor.living_room_humidity
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
        "light.bedroom"
        "light.livingroom"
      ];
      tap_action = "toggle";
      hold_action = "more-info";
      state_action = [{
        action = "call-service";
        service = "floorplan.style_set";
        service_data = ''
          >
          var color = 'black'

          if (entity.state === 'on') {
            if (entity.attributes.rgb_color) {
              var rgb = entity.attributes.rgb_color
            }
            else if (entity.attributes.color_temp) {
              var rgb = util.color.miredToRGB(entity.attributes.color_temp)
            }
              color = `rgb($${rgb[0]}, $${rgb[1]}, $${rgb[2]})`
          }

          return `fill= $${color};`
        '';
      }];
    }
  ];
}
