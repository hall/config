{ kubenix, vars, ... }:
vars.simple {
  inherit kubenix;
  image = "photoprism/photoprism:v0.16.1";
  port = 9999;
  persistence = {
    media.size = "30Gi";
    config.mountPath = "/root/.stash";
  };
}
