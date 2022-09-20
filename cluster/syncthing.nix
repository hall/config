{ kubenix, vars, ... }:
vars.simple {
  inherit kubenix;
  image = "syncthing/syncthing:1.21";
  port = 8384;
  host = "sync";
  persistence = {
    stash.existingClaim = "stash-media";
    notes.size = "5Gi";
    cloud.size = "60Gi";
    library.size = "10Gi";
    sessions.size = "10Gi";
    config = {
      size = "1Gi";
      mountPath = "/var/syncthing";
    };
  };
  values.service.nodeport = {
    enabled = true;
    type = "NodePort";
    externalTrafficPolicy = "Local";
    ports = {
      listen = {
        enabled = true;
        port = 22000;
        protocol = "TCP";
        targetPort = 22000;
      };
      discovery = {
        enabled = true;
        port = 21027;
        protocol = "UDP";
        targetPort = 21027;
      };
    };
  };
}
