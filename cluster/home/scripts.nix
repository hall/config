{ vars }: {
  configure_switches.sequence = [{
    service = "mqtt.publish";
    data = {
      topic = "zigbee2mqtt/switches/set";
      payload = vars.json {
        outputMode = "Dimmer";
        doubleTapUpForFullBrightness = "Button Press Event + Set Load to 100%";
        buttonDelay = "100ms";
        # all other dimming speeds key off this by default
        dimmingSpeedUpRemote = 5; # * 100ms
        defaultLed1ColorWhenOn = 250;
        defaultLed1ColorWhenOff = 250;
        defaultLed2ColorWhenOn = 210;
        defaultLed2ColorWhenOff = 210;
        defaultLed3ColorWhenOn = 160;
        defaultLed3ColorWhenOff = 160;
        defaultLed4ColorWhenOn = 120;
        defaultLed4ColorWhenOff = 120;
        defaultLed5ColorWhenOn = 80;
        defaultLed5ColorWhenOff = 80;
        defaultLed6ColorWhenOn = 40;
        defaultLed6ColorWhenOff = 40;
        defaultLed7ColorWhenOn = 20;
        defaultLed7ColorWhenOff = 20;
      };
    };
  }];
  #   printer = {
  #     printer_home.sequence = [{
  #       service = "mqtt.publish";
  #       data = {
  #         topic = "octoPrint/hassControl/home";
  #         payload = ''["x", "y", "z"]'';
  #       };
  #     }];
  #   };
}
