{ flake, ... }: {
  ".common" = {
    esphome.name = "$name";

    sensor = [{
      platform = "uptime";
      name = "$name Uptime";
    }];
    logger.level = "INFO";

    ota.password = "!secret esphome";

    mqtt.broker = "mqtt.${flake.lib.hostname}";
  };
}
