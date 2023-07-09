{ lib, kubenix, flake, ... }: {
  kubernetes = {
    resources = {
      namespaces.monitoring.metadata.labels = {
        "goldilocks.fairwinds.com/enabled" = "true";
        "goldilocks.fairwinds.com/vpa-update-mode" = "auto";
      };

      # kubectl -n monitoring get secret/dashboard -o go-template='{{.data.token | base64decode}}'
      serviceAccounts.admin.metadata.namespace = "monitoring";
      secrets.dashboard = {
        metadata = {
          namespace = "monitoring";
          annotations."kubernetes.io/service-account.name" = "admin";
        };
        type = "kubernetes.io/service-account-token";
      };
      clusterRoleBindings.admin = {
        metadata.namespace = "monitoring";
        roleRef = {
          apiGroup = "rbac.authorization.k8s.io";
          kind = "ClusterRole";
          name = "cluster-admin";
        };
        subjects = [{
          kind = "ServiceAccount";
          name = "admin";
          namespace = "monitoring";
        }];
      };

      ingresses.kubernetes-dashboard = {
        metadata.namespace = "monitoring";
        spec.tls = lib.mkForce [ ];
      };
      # TODO: must set 'protocol`
      services = {
        kubernetes-dashboard-api = {
          metadata.namespace = "monitoring";
          spec.ports = lib.mkForce [{
            name = "api";
            port = 9000;
            protocol = "TCP";
          }];
        };
        kubernetes-dashboard-web = {
          metadata.namespace = "monitoring";
          spec.ports = lib.mkForce [{
            name = "web";
            port = 8000;
            protocol = "TCP";
          }];
        };
        kubernetes-dashboard-metrics-scraper = {
          metadata.namespace = "monitoring";
          spec.ports = lib.mkForce [{
            port = 8000;
            protocol = "TCP";
          }];
        };
      };
    };

    helm.releases = {
      kubernetes-dashboard = {
        namespace = "monitoring";
        chart = kubenix.lib.helm.fetch {
          repo = "https://kubernetes.github.io/dashboard/";
          chart = "kubernetes-dashboard";
          version = "7.0.0";
          sha256 = "KNDRl+N79Xv+tONrUlVdoIC+a/ahEvY0jokHuvXGVk8=";
        };
        values = {
          nginx.enabled = false;
          nginx-ingress.enabled = false;
          cert-manager.enabled = false;
          metrics-server.enabled = false;
          app.ingress = {
            hosts = [ "dashboard.${flake.lib.hostname}" ];
            ingressClassName = "traefik";
            # disable creation of cert-manager issuer
            issuer = "no";
          };
        };
      };

      kube-prometheus-stack = {
        chart = kubenix.lib.helm.fetch {
          repo = "https://prometheus-community.github.io/helm-charts";
          chart = "kube-prometheus-stack";
          version = "46.4.1";
          sha256 = "s+uOIAQ36XHEKmTHwflZv8K3khm8u2/onacscgqgc2U=";
        };
        namespace = "monitoring";
        # includeCRDs = true; # fails
        # noHooks = true;
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
                resources.requests.storage = "100Gi";
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
                    "bedroom:9100"
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
    };
    customTypes = {
      servicemonitors = {
        attrName = "servicemonitors";
        group = "monitoring.coreos.com";
        version = "v1";
        kind = "ServiceMonitor";
      };
      podmonitors = {
        attrName = "podmonitors";
        group = "monitoring.coreos.com";
        version = "v1";
        kind = "PodMonitor";
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
  };


}
