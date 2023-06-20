{ ... }: {
  space-heater-power = {
    packages.plug = "!include .plug.yaml";
    substitutions.name = "space-heater-power";
  };
  tv-light = {
    packages.temphumid = "!include .temphumid.yaml";
    substitutions.name = "tv-light";
    e131 = { }; # port 5568
    light = [{
      platform = "neopixelbus";
      variant = "WS2812";
      pin = "GPIO3"; # "RX"
      num_leds = 146; # 26 x 47 rectangle
      name = "tv";
      method.type = "esp8266_dma";
      effects = [{
        e131.universe = 1;
      }];
    }];
  };
  piano-keys = {
    packages.wifi = "!include .wifi.yaml";
    substitutions.name = "piano-keys";
    esphome = {
      platform = "ESP8266";
      board = "nodemcuv2";
      on_boot = [{
        "light.turn_on" = {
          id = "piano";
          effect = "instruct";
        };
      }];
    };
    light = [{
      name = "piano";
      id = "piano";
      num_leds = 88;
      pin = "GPIO12"; # "D6"
      platform = "neopixelbus";
      variant = "WS2812";
      effects = [{
        addressable_lambda = {
          name = "instruct";
          update_interval = "50ms";
          lambda = ''
            while ((Serial.available()) > 0) {
              int inp = atoi(Serial.readStringUntil('\n').c_str());
              switch (inp) {
                case 0 ... 87:
                  if (it[inp].get().is_on()) {
                    it[inp] = Color::BLACK;
                  } else {
                    it[inp] = Color(50,50,50,50);
                  }
                  break;
                case 88:
                  it.all() = Color::BLACK;
                  break;
                default: 
                  ESP_LOGI("midi", "invalid input: %i", inp);
              }
            }
          '';
        };
      }];
    }];
    # move logger off usb uart port
    logger.hardware_uart = "UART1";
    uart = {
      tx_pin = "GPIO1";
      rx_pin = "GPIO3";
      baud_rate = 9600;
    };
  };
}
