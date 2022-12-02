{ ... }: {
  ".temphumid" = {
    packages.wifi = "!include .wifi.yaml";

    esphome = {
      platform = "ESP8266";
      board = "nodemcuv2";
    };

    sensor = [{
      platform = "dht";
      pin = "D1";
      model = "AM2302";
      temperature.name = "$name Temperature";
      humidity.name = "$name Humidity";
    }];
  };
}
