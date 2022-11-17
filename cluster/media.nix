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
    values = {
      probes = {
        startup.enabled = false;
        liveness = {
          custom = true;
          spec.exec.command = [
            "/usr/bin/env"
            "bash"
            "-c"
            "curl --fail localhost:8989/api/v3/system/status?apiKey=`IFS=\> && while"
            "read -d \< E C; do if [[ $E = 'ApiKey' ]]; then echo $C; fi; done < /config/config.xml`"
          ];
        };
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
