{ ... }: {
  ".wifi" = {
    packages.common = "!include .common.yaml";

    wifi = {
      ssid = "hall";
      password = "!secret wifi";
      domain = "";

      ap = {
        ssid = "$name Hotspot";
        password = "!secret wifi";
      };
    };

    captive_portal = { };

    sensor = [{
      platform = "wifi_signal";
      name = "$name WiFi Strength";
      update_interval = "60s";
    }];
  };
}
