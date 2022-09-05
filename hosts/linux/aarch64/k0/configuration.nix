{ flake, lib, ... }:
{
  imports = [
    flake.inputs.hardware.nixosModules.raspberry-pi-4
  ];

  services.k8s = {
    enable = true;
    role = "server";
    serverAddr = lib.mkForce "";
  };
  systemd.services.k3s.environment = {
    K3S_CLUSTER_INIT = "true";
  };
}
