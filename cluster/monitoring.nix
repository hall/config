{ kubenix, flake, ... }:
let
  ns = "system";
in
{
  helm.releases.kube-prometheus-stack = {
    chart = kubenix.lib.helm.fetch {
      repo = "https://prometheus-community.github.io/helm-charts";
      chart = "kube-prometheus-stack";
      version = "39.11.0";
      sha256 = "sha256-6Zwy+74Vb8qRNXzCjirAjxj94DZB/J9eKj1VJib/fBE=";
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
          externalUrl = "https://prometheus.${flake.hostname}";
          serviceMonitorSelectorNilUsesHelmValues = false;
          podMonitorSelectorNilUsesHelmValues = false;
        };
        ingress = {
          enabled = true;
          hosts = [ "prometheus.${flake.hostname}" ];
          pathType = "ImplementationSpecific";
        };
      };

      alertmanager = {
        alertmanagerSpec.externalUrl = "https://alertmanager.${flake.hostname}";
        ingress = {
          enabled = true;
          hosts = [ "alertmanager.${flake.hostname}" ];
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
            {
              name = "null";
            }
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
          hosts = [ "grafana.${flake.hostname}" ];
          pathType = "ImplementationSpecific";
        };
      };

      nodeExporter.serviceMonitor.relabelings = [{
        sourceLabels = [ "__meta_kubernetes_pod_node_name" ];
        targetLabels = "instance";
        action = "replace";
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