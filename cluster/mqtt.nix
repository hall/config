{ kubenix, flake, vars, ... }:
let
  ns = "system";
in
{
  resources.ingressroutetcp.mosquitto = {
    metadata.namespace = ns;
    spec = {
      entryPoints = [ "mqtt" ];
      routes = [{
        match = "HostSNI(`*`)";
        services = [{
          name = "mosquitto";
          port = 1883;
          namespace = ns;
        }];
      }];
    };
  };

  helm.releases.mosquitto = {
    chart = vars.template { inherit kubenix; };
    namespace = "system";
    values = {
      image = {
        repository = "eclipse-mosquitto";
        tag = "2.0.14";
      };
      service.main.ports = {
        http.enabled = false;
        mqtt = {
          enabled = true;
          port = 1883;
        };
      };
      configmap.config = {
        enabled = true;
        data.config = ''
          listener 1883
          allow_anonymous true
        '';

        # persistence true
        # persistence_location {{ .Values.persistence.data.mountPath }}
        # autosave_interval 1800
      };
      persistence = {
        config = {
          enabled = true;
          type = "configMap";
          subPath = "config";
          mountPath = "/mosquitto/config/mosquitto.conf";
          name = "mosquitto-config";
          readOnly = true;
        };
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
}
