{ kubenix, vars, flake, ... }:
vars.simple {
  inherit kubenix;
  image = "octoprint/octoprint:1.8.6";
  port = 80;
  persistence = {
    data = {
      enabled = true;
      mountPath = "/octoprint";
    };
    printer = {
      enabled = true;
      type = "hostPath";
      hostPath = "/dev/ttyACM0";
    };
  };
  # prevent clashing of automatic variables
  # https://github.com/OctoPrint/octoprint-docker/issues/160#issuecomment-753364398
  values = {
    env.OCTOPRINT_PORT = "80";
    nodeSelector."${flake.hostname}/printer" = "true";
  };
}