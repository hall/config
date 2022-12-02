{ ... }: {
  zigbee = {
    packages = {
      common = "!include .common.yaml";
      upstream = "github://tube0013/tube_gateways/models/current/tubeszb-cc2652-poe-2022/firmware/esphome/source/tubeszb-cc2652-poe-2022.yaml";
    };

    esphome.name = "zigbee";

    ethernet.use_address = "tubeszb-cc2652-poe-2022";
  };
}
