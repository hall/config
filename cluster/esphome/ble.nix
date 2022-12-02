{ ... }: {
  ble-tracker = {
    packages.common = "!include .common.yaml";
    substitutions.name = "ble-tracker";

    esphome = {
      platform = "ESP32";
      board = "nodemcu-32s";
    };

    esp32_ble_tracker.scan_parameters = {
      duration = "10s";
      active = false;
    };

    binary_sensor = [{
      platform = "ble_presence";
      mac_address = "!secret mac_car";
      name = "car";
      filters = [
        "delayed_off= 10s"
      ];
    }];

    sensor = [{
      platform = "dht";
      pin = "GPIO13";
      model = "AM2302";
      temperature.name = "Garage Temperature";
      humidity.name = "Garage Humidity";
    }];
  };
}
