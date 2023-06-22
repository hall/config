{ kubenix, flake, lib, ... }: {
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
          nodeSelector."node-role.kubernetes.io/control-plane" = "true";
          tolerations = [{
            key = "node-role.kubernetes.io/control-plane";
            operator = "Exists";
            effect = "NoSchedule";
          }];
        };
      };

      autoscaler =
        let
          tolerations = [{
            key = "node-role.kubernetes.io/control-plane";
            operator = "Exists";
            effect = "NoSchedule";
          }];
          nodeSelector."node-role.kubernetes.io/control-plane" = "true";
        in
        {
          chart = kubenix.lib.helm.fetch {
            repo = "https://charts.fairwinds.com/stable";
            chart = "vpa";
            version = "2.1.0";
            sha256 = "imzK9FoOs5fAZjqtcd977zrfNyreTaSjWaGt5LQznrI=";
          };
          namespace = "kube-system";
          # includeCRDs = true;
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
