{ ... }: {
  ".plug" = {
    packages.wifi = "!include .wifi.yaml";

    esphome = {
      platform = "ESP8266";
      board = "esp01_1m";
    };

    logger.baud_rate = 0; # (UART logging interferes with cse7766)

    uart = {
      rx_pin = "RX";
      baud_rate = 4800;
    };

    binary_sensor = [
      {
        platform = "gpio";
        pin = {
          number = "GPIO0";
          mode = "INPUT_PULLUP";
          inverted = true;
        };
        name = "$name button";
        on_press = [
          { "switch.toggle" = "relay"; }
        ];
      }
      {
        platform = "status";
        name = "$name status";
      }
    ];
    sensor = [{
      platform = "cse7766";
      current = {
        name = "$name current";
        accuracy_decimals = 1;
      };
      voltage = {
        name = "$name voltage";
        accuracy_decimals = 1;
      };
      power = {
        name = "$name power";
        accuracy_decimals = 1;
      };
    }];
    switch = [{
      platform = "gpio";
      name = "$name relay";
      pin = "GPIO12";
      id = "relay";
    }];

    status_led.pin = "GPIO13";

  };
}
