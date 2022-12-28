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
      pin = "GPIO3"; # RX
      num_leds = 146; # 26 x 47 rectangle
      name = "tv";
      method.type = "esp8266_dma";
      effects = [{
        e131.universe = 1;
      }];
    }];
  };
}
