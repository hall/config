{ ... }: {
  ".rgbww" = {
    packages.wifi = "!include .wifi.yaml";

    esphome = {
      platform = "ESP8266";
      board = "esp01_1m";
      esp8266_restore_from_flash = true;
    };

    switch = [{
      platform = "restart";
      name = "\${name} Restart";
    }];
    output = [
      {
        platform = "esp8266_pwm";
        id = "output_red";
        pin = "GPIO5";
      }
      {
        platform = "esp8266_pwm";
        id = "output_green";
        pin = "GPIO4";
      }
      {
        platform = "esp8266_pwm";
        id = "output_blue";
        pin = "GPIO13";
      }
      {
        platform = "esp8266_pwm";
        id = "output_cold_white";
        pin = "GPIO14";
      }
      {
        platform = "esp8266_pwm";
        id = "output_warm_white";
        pin = "GPIO12";
      }
    ];

    #sensor:
    #  - platform: uptime
    #    id: up

    light = [{
      platform = "rgbww";
      # name: $id
      id = "$id";
      red = "output_red";
      green = "output_green";
      blue = "output_blue";
      default_transition_length = "1s";
      warm_white = "output_warm_white";
      cold_white = "output_cold_white";
      cold_white_color_temperature = "6000 K";
      warm_white_color_temperature = "2700 K";
      # TODO: add smart switches?
      restore_mode = "RESTORE_DEFAULT_ON";
      # on_turn_on:
      #   if:
      #     condition:
      #       lambda: return id(up).state < 10; # seconds
      #     then:
      #       light.turn_on:
      #         id: light_bedroom
      #         brightness: 100%
      #         #color_brightness: 100%

    }];
  };
}
