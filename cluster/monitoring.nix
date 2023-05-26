{ kubenix, flake, ... }:
let
  ns = "system";
in
{
  helm.releases.kube-prometheus-stack = {
    chart = kubenix.lib.helm.fetch {
      repo = "https://prometheus-community.github.io/helm-charts";
      chart = "kube-prometheus-stack";
      version = "46.4.1";
      sha256 = "s+uOIAQ36XHEKmTHwflZv8K3khm8u2/onacscgqgc2U=";
    };
    namespace = ns;
    values = {
      kubeControllerManager.enabled = false;
      kubeScheduler.enabled = false;
      kubeProxy.enabled = false;
      kubeEtcd.enabled = false;
      coreDns.enabled = false; # ns conflict

      prometheus = {
        prometheusSpec = {
          externalUrl = "https://prometheus.${flake.lib.hostname}";
          serviceMonitorSelectorNilUsesHelmValues = false;
          podMonitorSelectorNilUsesHelmValues = false;
          storageSpec.volumeClaimTemplate.spec = {
            storageClassName = "longhorn-static";
            accessModes = [ "ReadWriteOnce" ];
            resources.requests.storage = "50Gi";
          };
          additionalScrapeConfigs = [{
            job_name = "node-exporter";
            relabel_configs = [{
              regex = "(.*):(.*)";
              source_labels = [ "__address__" ];
              target_label = "instance";
            }];
            static_configs = [{
              # TODO: don't hardcode
              targets = [
                "router:9100"
                "tv:9100"
                "office:9100"
                # "bedroom:9100"
              ];
            }];
          }];
        };
        ingress = {
          enabled = true;
          hosts = [ "prometheus.${flake.lib.hostname}" ];
          pathType = "ImplementationSpecific";
        };
      };

      alertmanager = {
        alertmanagerSpec.externalUrl = "https://alertmanager.${flake.lib.hostname}";
        ingress = {
          enabled = true;
          hosts = [ "alertmanager.${flake.lib.hostname}" ];
          pathType = "ImplementationSpecific";
        };
        config = {
          global.resolve_timeout = "5m";
          route = {
            receiver = "matrix";
            group_by = [ "job" ];
            group_wait = "30s";
            group_interval = "5m";
            repeat_interval = "12h";
            routes = [{
              receiver = "null";
              match.alertname = "Watchdog";
            }];
          };
          receivers = [
            { name = "null"; }
            {
              name = "matrix";
              webhook_configs = [{
                url = "http://go-neb.default:4050/services/hooks/Z28tbmVi";
              }];
            }
          ];
        };
      };

      grafana = {
        "grafana.ini" = {
          "auth.anonymous" = {
            enabled = true;
            org_name = "Main Org.";
            org_role = "Viewer";
          };
          security.allow_embedding = true;
        };
        ingress = {
          enabled = true;
          hosts = [ "grafana.${flake.lib.hostname}" ];
          pathType = "ImplementationSpecific";
        };
        dashboardProviders."dashboardproviders.yaml" = {
          apiVersion = 1;
          providers = [{
            name = "default";
            orgId = 1;
            folder = "";
            type = "file";
            disableDeletion = true;
            editable = true;
            options.path = "/var/lib/grafana/dashboards/default";
          }];
        };
        dashboards.default = {
          node-exporter-full = {
            gnetId = 1860;
            revision = 31;
            datasource = "Prometheus";
          };
        };
      };

      prometheus-node-exporter.prometheus.monitor.relabelings = [{
        sourceLabels = [ "__meta_kubernetes_pod_node_name" ];
        targetLabel = "instance";
      }];

    };
  };
  customTypes = {
    servicemonitors = {
      attrName = "servicemonitors";
      group = "monitoring.coreos.com";
      version = "v1";
      kind = "ServiceMonitor";
    };
    alertmanagers = {
      attrName = "alertmanagers";
      group = "monitoring.coreos.com";
      version = "v1";
      kind = "Alertmanager";
    };
    prometheus = {
      attrName = "prometheus";
      group = "monitoring.coreos.com";
      version = "v1";
      kind = "Prometheus";
    };
    prometheusrule = {
      attrName = "prometheusrule";
      group = "monitoring.coreos.com";
      version = "v1";
      kind = "PrometheusRule";
    };
  };

}
