{ kubenix, vars, ... }:
vars.simple {
  inherit kubenix;
  image = "stashapp/stash:v0.20.1";
  port = 9999;
  persistence = {
    media = {
      size = "50Gi";
      accessMode = "ReadWriteMany";
    };
    config = {
      size = "10Gi";
      mountPath = "/root/.stash";
    };
  };
}
