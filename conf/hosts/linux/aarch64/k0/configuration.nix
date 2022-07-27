{ ... }:
{
  environment.variables.K3S_CLUSTER_INIT = "true";
  services.k3s = {
    enable = true;
    role = "server";
  };
}
