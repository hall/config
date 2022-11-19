{ kubenix, vars, flake, ... }:
let
  pvc = "transmission-downloads";
in
flake.lib.recursiveMerge [
  (vars.simple {
    inherit kubenix;
    image = "linuxserver/transmission:version-3.00-r6";
    port = 9091;
    persistence = {
      config = { };
      downloads = {
        size = "200Gi";
        accessMode = "ReadWriteMany";
      };
    };
  })

  (vars.simple {
    inherit kubenix;
    image = "linuxserver/sonarr:3.0.9";
    port = 8989;
    persistence = {
      config.enabled = true;
      media.existingClaim = pvc;
    };
  })

]
