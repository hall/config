{ kubenix, vars, flake, ... }:
let
  pvc = "transmission-downloads";
in
flake.lib.recursiveMerge [
  (vars.simple {
    inherit kubenix;
    image = "linuxserver/transmission:version-3.00-r6";
    host = "downloads";
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
    image = "jellyfin/jellyfin:10.8.8";
    host = "player";
    port = 8096;
    persistence = {
      config.enabled = true;
      media.existingClaim = pvc;
    };
  })

  (vars.simple {
    inherit kubenix;
    image = "linuxserver/sonarr:3.0.9";
    host = "movies";
    port = 8989;
    persistence = {
      config.enabled = true;
      media.existingClaim = pvc;
    };
  })

  (vars.simple {
    inherit kubenix;
    image = "linuxserver/radarr:4.3.2";
    host = "shows";
    port = 7878;
    persistence = {
      config.enabled = true;
      media.existingClaim = pvc;
    };
  })

  (vars.simple {
    inherit kubenix;
    image = "linuxserver/lidarr:1.0.2";
    host = "music";
    port = 8686;
    persistence = {
      config.enabled = true;
      media.existingClaim = pvc;
    };
  })

]
