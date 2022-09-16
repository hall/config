{ kubenix, flake, lib, ... }:
let
  # required?
  ns = "kube-system";
in
{
  helm.releases.lb = {
    chart = kubenix.lib.helm.fetch {
      repo = "https://kube-vip.github.io/helm-charts";
      chart = "kube-vip";
      version = "0.4.2";
      sha256 = "sha256-hAzJmoLvV/uczEkpoic8bJNt38OSEbnYjNr8hU2IEJs=";
    };
    namespace = ns;
    values = {
      config.address = "192.168.1.7";
      env.cp_enable = "true";
      affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms = [{
        matchExpressions = [{
          key = "node-role.kubernetes.io/control-plane";
          operator = "Exists";
        }];
      }];
    };
  };

}
