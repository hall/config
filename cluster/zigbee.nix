{ kubenix, vars, ... }:
vars.simple {
  inherit kubenix;
  image = "koenkk/zigbee2mqtt:1.28.4";
  port = 8080;
  host = "zigbee";
  persistence = {
    data = {
      enabled = true;
      mountPath = "/app/data";
    };
  };
}
