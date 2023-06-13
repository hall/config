{ kubenix, vars, flake, ... }: {
  submodules.instances.octoprint = {
    submodule = "release";
    args = {
      image = "octoprint/octoprint:1.8.6";
      port = 80;
      host = "octoprint";
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
      values = {
        ingress.main.annotations = {
          "traefik.ingress.kubernetes.io/router.middlewares" = "kube-system-home@kubernetescrd";
        };
        # prevent clashing of automatic variables
        # https://github.com/OctoPrint/octoprint-docker/issues/160#issuecomment-753364398
        env.OCTOPRINT_PORT = "80";
        nodeSelector."${flake.lib.hostname}/printer" = "true";
        securityContext.privileged = true;
      };
    };
  };
}
