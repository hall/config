{ kubenix, flake, vars, ... }: {
  kubernetes.resources.ingressroutetcp.mosquitto.spec = {
    entryPoints = [ "mqtt" ];
    routes = [{
      match = "HostSNI(`*`)";
      services = [{
        name = "mosquitto";
        port = 1883;
      }];
    }];
  };

  submodules.instances.mosquitto = {
    submodule = "release";
    args = {
      image = "eclipse-mosquitto:2.0.14";
      values = {
        service.main.ports = {
          http.enabled = false;
          mqtt = {
            enabled = true;
            port = 1883;
          };
        };
        configMaps.config = {
          enabled = true;
          data.config = ''
            listener 1883
            allow_anonymous true
            connection_messages false
          '';

          # persistence true
          # persistence_location {{ .Values.persistence.data.mountPath }}
          # autosave_interval 1800
        };
        persistence.config = {
          enabled = true;
          type = "configMap";
          subPath = "config";
          mountPath = "/mosquitto/config/mosquitto.conf";
          name = "mosquitto-config";
          readOnly = true;
        };
        # ingress.main = {
        #   enabled = true;
        #   hosts = [{
        #     host = "mqtt.${flake.lib.hostname}";
        #     paths = [{ path = "/"; }];
        #   }];
        # };
      };
    };
  };
}
