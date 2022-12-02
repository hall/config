{ ... }: {
  konnected = {
    packages.common = "!include .common.yaml";
    substitutions.name = "konnected";

    esphome = {
      platform = "ESP32";
      board = "wesp32";
    };

    ethernet = {
      type = "LAN8720";
      mdc_pin = "GPIO16";
      mdio_pin = "GPIO17";
      clk_mode = "GPIO0_IN";
      phy_addr = 0;
      domain = ".lan";
    };

    binary_sensor = [
      {
        platform = "gpio";
        name = "Front Door";
        device_class = "door";
        pin = {
          number = "GPIO4"; # zone 1
          mode = "INPUT_PULLUP";
        };
      }
      {
        platform = "gpio";
        name = "Back Door";
        device_class = "door";
        pin = {
          number = "GPIO2"; # zone 2
          mode = "INPUT_PULLUP";
        };
      }
      {
        platform = "gpio";
        name = "Kitchen Door";
        device_class = "door";
        pin = {
          number = "GPIO15"; # zone 3
          mode = "INPUT_PULLUP";
        };
      }
      #- platform: gpio
      #  name: Zone 4
      #  device_class: window
      #  pin:
      #    number: GPIO13
      #    mode: INPUT_PULLUP
      #- platform: gpio
      #  name: Zone 5
      #  device_class: motion
      #  pin:
      #    number: GPIO18
      #    mode: INPUT_PULLUP
      #- platform: gpio
      #  name: Zone 6
      #  device_class: motion
      #  pin:
      #    number: GPIO14
      #    mode: INPUT_PULLUP
      #- platform: gpio
      #  name: Zone 7
      #  pin:
      #    number: GPIO33
      #    mode: INPUT_PULLUP
      #- platform: gpio
      #  name: Zone 8
      #  pin:
      #    number: GPIO32
      #    mode: INPUT_PULLUP
      #- platform: gpio
      #  name: Zone 9
      #  pin:
      #    number: GPIO36
      #    mode: INPUT_PULLUP
      #- platform: gpio
      #  name: Zone 10
      #  pin:
      #    number: GPIO39
      #    mode: INPUT_PULLUP
      #- platform: gpio
      #  name: Zone 11
      #  pin:
      #    number: GPIO34
      #    mode: INPUT_PULLUP
      #- platform: gpio
      #  name: Zone 12
      #  pin:
      #    number: GPIO35
      #    mode: INPUT_PULLUP
    ];
    #switch:
    #  - platform: gpio
    #    name: Siren
    #    pin: GPIO12 # ALARM1
    #
    #  - platform: gpio
    #    name: Strobe
    #    pin: GPIO5  # ALARM2
    #
    #  - platform: gpio
    #    name: Status LED
    #    pin: GPIO3
    #
    #  # with a piezo buzzer, beep 3 times
    #  - platform: gpio
    #    pin: GPIO23 # OUT1
    #    id: beep
    #  - platform: template
    #    name: Beep beep beep
    #    turn_on_action:
    #      - switch.turn_on: beep
    #      - delay: 60ms
    #      - switch.turn_off: beep
    #      - delay: 60ms
    #      - switch.turn_on: beep
    #      - delay: 60ms
    #      - switch.turn_off: beep
    #      - delay: 60ms
    #      - switch.turn_on: beep
    #      - delay: 60ms
    #      - switch.turn_off: beep


  };
}
