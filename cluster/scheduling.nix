{ kubenix, flake, lib, ... }:
let
  tolerations = [{
    key = "node-role.kubernetes.io/control-plane";
    operator = "Exists";
    effect = "NoSchedule";
  }];
  nodeSelector."node-role.kubernetes.io/control-plane" = "true";
in
{
  kubernetes = {
    helm.releases = {
      descheduler = {
        chart = kubenix.lib.helm.fetch {
          repo = "https://kubernetes-sigs.github.io/descheduler";
          chart = "descheduler";
          version = "0.27.1";
          sha256 = "8tH+4mNmr5Z7BNbnW6OmKTHaWyjXnwlcLAsBU5RN85Q=";
        };
        namespace = "kube-system";
        values = {
          kind = "Deployment";
          service.enabled = true;
          serviceMonitor.enabled = true;
          inherit tolerations nodeSelector;
        };
      };

      autoscaler = {
        chart = kubenix.lib.helm.fetch {
          repo = "https://charts.fairwinds.com/stable";
          chart = "vpa";
          version = "2.1.0";
          sha256 = "imzK9FoOs5fAZjqtcd977zrfNyreTaSjWaGt5LQznrI=";
        };
        namespace = "kube-system";
        includeCRDs = true;
        # TODO: tests fail due to missing service account
        noHooks = true;
        values = {
          admissionController = {
            inherit tolerations nodeSelector;
            certGen = {
              inherit tolerations nodeSelector;
            };
          };
          recommender = {
            inherit tolerations nodeSelector;
            podMonitor.enabled = true;
            extraArgs = {
              prometheus-address = "http://prometheus-operated.monitoring:9090";
              storage = "prometheus";
            };
          };
          updater = {
            podMonitor.enabled = true;
            inherit tolerations nodeSelector;
          };
        };
      };
      goldilocks = {
        chart = kubenix.lib.helm.fetch {
          repo = "https://charts.fairwinds.com/stable";
          chart = "goldilocks";
          version = "6.7.0";
          sha256 = "HKq1tTeww69YSAt3kkHUnCDZnW3UjIFapFUKXt8ty0E=";
        };
        namespace = "kube-system";
        values = {
          controller = {
            inherit tolerations nodeSelector;
            resources.limits.cpu = null; #"400m";
            rbac.extraRules = [
              {
                apiGroups = [ "batch" ];
                resources = [ "cronjobs" "jobs" ];
                verbs = [ "get" "list" "watch" ];
              }
              {
                apiGroups = [ "monitoring.coreos.com" ];
                resources = [ "alertmanagers" ];
                verbs = [ "get" "list" "watch" ];
              }
            ];
          };
          dashboard = {
            inherit tolerations nodeSelector;
            replicaCount = 1;
            resources.limits.cpu = "100m";
            ingress = {
              enabled = true;
              hosts = [{
                host = "goldilocks.${flake.lib.hostname}";
                paths = [{
                  path = "/";
                  type = "ImplementationSpecific";
                }];
              }];
            };
          };
        };
      };
    };
    # TODO: must set 'protocol`
    resources.services.autoscaler-vpa-webhook = {
      metadata.namespace = "kube-system";
      spec.ports = lib.mkForce [{
        port = 443;
        targetPort = 8000;
        protocol = "TCP";
      }];
    };
    # customTypes.vpa = {
    #   attrName = "vpa";
    #   group = "autoscaling.k8s.io";
    #   version = "v1";
    #   kind = "VerticalPodAutoscaler";
    # };
  };
}
