{ kubenix, vars, ... }:
vars.simple {
  inherit kubenix;
  image = "stashapp/stash:v0.16.1";
  port = 9999;
  persistence = {
    media = {
      size = "50Gi";
      accessMode = "ReadWriteMany";
    };
    config.mountPath = "/root/.stash";
  };
}
