{ ... }: {
  printer-power = {
    packages.plug = "!include .plug.yaml";
    substitutions.name = "printer-power";
  };
  printer-camera = {
    packages.wifi = "!include .wifi.yaml";
    substitutions.name = "printer-camera";

    esphome = {
      platform = "ESP32";
      board = "esp32dev";
    };

    # Enable Home Assistant API
    api.reboot_timeout = "0s";

    esp32_camera = {
      name = "printer";
      external_clock = {
        pin = "GPIO0";
        frequency = "20MHz";
      };
      i2c_pins = {
        sda = "GPIO26";
        scl = "GPIO27";
      };
      data_pins = [ "GPIO5" "GPIO18" "GPIO19" "GPIO21" "GPIO36" "GPIO39" "GPIO34" "GPIO35" ];
      vsync_pin = "GPIO25";
      href_pin = "GPIO23";
      pixel_clock_pin = "GPIO22";
      power_down_pin = "GPIO32";
    };

    # Flashlight
    output = [{
      platform = "gpio";
      pin = "GPIO4";
      id = "gpio_4";
    }];

    ## GPIO_4 is the flash light pin
    light = [{
      platform = "binary";
      output = "gpio_4";
      name = "$name Light";
    }];
  };

}

