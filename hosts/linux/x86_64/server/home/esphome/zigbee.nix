{ config, lib, ... }: {
  # .common.yaml
  # TODO: version?
  packages.upstream = "github://tube0013/tube_gateways/models/current/tubeszb-cc2652-poe-2022/firmware/esphome/tubeszb-cc2652-poe-2022.yaml@main";

  esphome.name = "zigbee";

  # TODO: why hostname doesn't work?
  ethernet.use_address =
    lib.removePrefix "tcp://"
      (lib.removeSuffix ":6638"
        config.services.zigbee2mqtt.settings.serial.port);
}
