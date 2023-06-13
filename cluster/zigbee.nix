{ kubenix, vars, ... }: {
  submodules.instances.zigbee2mqtt = {
    submodule = "release";
    args = {
      image = "koenkk/zigbee2mqtt:1.28.4";
      port = 8080;
      host = "zigbee";
      persistence.data.mountPath = "/app/data";
    };
  };
}
