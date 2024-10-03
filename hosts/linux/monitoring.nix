{ config, ... }: {
  systemd.services.alloy.serviceConfig.EnvironmentFile = config.age.secrets.grafana.path;
  # changes done in the grafana cloud console
  #  - /connections/add-new-connection/hass
  services.alloy = {
    enable = true;
    extraFlags = [
      # TODO: throws TLS errors b/c its getting the wrong/local cert
      "--disable-reporting"
    ];
  };
  environment.etc = {
    "alloy/config.alloy".text = ''
      logging {
        level = "warn"
      }

      tracing {
        sampling_fraction = 0.1
        write_to = [otelcol.exporter.otlp.default.input]
      }
    '';

    "alloy/metrics.alloy".text = ''
      prometheus.remote_write "default" {
        endpoint {
          url = "https://prometheus-prod-13-prod-us-east-0.grafana.net/api/prom/push"
          basic_auth {
            username = sys.env("PROMETHEUS_USERNAME")
            password = sys.env("GRAFANA_PASSWORD")
          }
        }
      }

      prometheus.relabel "all" {
        forward_to = [prometheus.remote_write.default.receiver]
        rule {
          action       = "replace"
          target_label = "instance"
          replacement  = constants.hostname
        }
      }

      prometheus.exporter.unix "localhost" {}

      prometheus.scrape "node" {
        forward_to = [prometheus.relabel.all.receiver]
        targets    = prometheus.exporter.unix.localhost.targets
      }
    '';

    "alloy/logs.alloy".text = ''
      loki.write "default" {
        endpoint {
          url = "https://logs-prod-006.grafana.net/loki/api/v1/push"
    
          basic_auth {
            username = sys.env("LOKI_USERNAME")
            password = sys.env("GRAFANA_PASSWORD")
          }
        }
      }

      loki.relabel "journal" {
        forward_to = []
        rule {
          source_labels = ["__journal__systemd_unit"]
          target_label  = "unit"
        }
      }

      loki.source.journal "default" {
        forward_to    = [loki.write.default.receiver]
        relabel_rules = loki.relabel.journal.rules
        labels        = { instance = constants.hostname }
      }
    '';

    "alloy/traces.alloy".text = ''
      otelcol.exporter.otlp "default" {
        client {
          endpoint = "tempo-prod-04-prod-us-east-0.grafana.net:443"
          auth = otelcol.auth.basic.default.handler
        }
      }

      otelcol.auth.basic "default" {
        username = sys.env("OTELCOL_USERNAME")
        password = sys.env("GRAFANA_PASSWORD")
      }
    '';

    "alloy/home-assistant.alloy".text = ''
      discovery.relabel "metrics_integrations_integrations_hass" {
      	targets = [{
      		__address__ = "localhost:8123",
      	}]
      	rule {
      		target_label = "instance"
      		replacement  = constants.hostname
      	}
      }
    
      prometheus.scrape "metrics_integrations_integrations_hass" {
      	targets      = discovery.relabel.metrics_integrations_integrations_hass.output
      	forward_to   = [prometheus.remote_write.default.receiver]
      	job_name     = "integrations/hass"
      	metrics_path = "/api/prometheus"
      	scheme       = "http"
      	authorization {
      		type        = "Bearer"
      		credentials = sys.env("HASS_TOKEN")
      	}
      }
    '';
  };
}
