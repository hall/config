{ ... }: {
  recirculating-pump-power = {
    packages.plug = "!include .plug.yaml";
    substitutions.name = "recirculating-pump-power";
  };
  garage-door = {
    packages.common = "!include .common.yaml";
    substitutions.name = "garage-door";

    esphome = {
      platform = "ESP8266";
      board = "esp01_1m";
    };

    # the door contact sensor that is attached to SW;
    # used to set the state of the cover
    binary_sensor = [{
      platform = "gpio";
      pin = "GPIO5";
      name = "$name Contact Sensor";
      id = "contact_sensor";
      internal = true;
      filters = [ "invert:" ];
    }];

    # the relay that will deliver the pulse to the garage door opener
    switch = [{
      platform = "gpio";
      pin = "GPIO4";
      name = "$name Relay";
      id = "relay";
      internal = true;
    }];

    # this creates the actual garage door in HA
    cover = [{
      platform = "template";
      device_class = "garage";
      name = "$name";
      id = "template_cov";
      # the state is based on the contact sensor
      lambda = ''
        if (id(contact_sensor).state) {
          return COVER_OPEN;
        } else {
          return COVER_CLOSED;
        }
      '';
      # turn the relay on/off with a 0.5s delay in between
      open_action = [
        { "switch.turn_on" = "relay"; }
        { delay = "0.5s"; }
        { "switch.turn_off" = "relay"; }
      ];
      close_action = [
        { "switch.turn_on" = "relay"; }
        { delay = "0.5s"; }
        { "switch.turn_off" = "relay"; }
      ];
    }];
  };
}
