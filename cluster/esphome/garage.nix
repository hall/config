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
  # TODO: deploy
  power-monitor = {
    packages.common = "!include .wifi.yaml";
    substitutions.name = "power-monitor";
    esphome = {
      platform = "ESP32";
      board = "nodemcu-32s";
    };
    spi = {
      clk_pin = 18;
      miso_pin = 19;
      mosi_pin = 23;
    };
    sensor = [
      {
        platform = "atm90e32";
        cs_pin = 5;
        phase_a = {
          voltage.name = "EMON Line Voltage A";
          current.name = "EMON CT1 Current";
          power.name = "EMON Active Power CT1";
          gain_voltage = 7305;
          gain_ct = 12577;
        };
        phase_b = {
          current.name = "EMON CT2 Current";
          power.name = "EMON Active Power CT2";
          gain_voltage = 7305;
          gain_ct = 12577;
        };
        phase_c = {
          current.name = "EMON CT3 Current";
          power.name = "EMON Active Power CT3";
          gain_voltage = 7305;
          gain_ct = 12577;
        };
        frequency.name = "EMON Line Frequency";
        line_frequency = "50Hz";
        current_phases = 3;
        gain_pga = "1X";
        update_interval = "60s";
      }
      {
        platform = "atm90e32";
        cs_pin = 4;
        phase_a = {
          current.name = "EMON CT4 Current";
          power.name = "EMON Active Power CT4";
          gain_voltage = 7305;
          gain_ct = 12577;
        };
        phase_b = {
          current.name = "EMON CT5 Current";
          power.name = "EMON Active Power CT5";
          gain_voltage = 7305;
          gain_ct = 12577;
        };
        phase_c = {
          current.name = "EMON CT6 Current";
          power.name = "EMON Active Power CT6";
          gain_voltage = 7305;
          gain_ct = 12577;
        };
        line_frequency = "50Hz";
        current_phases = 3;
        gain_pga = "1X";
        update_interval = "60s";
      }
    ];
  };
}
