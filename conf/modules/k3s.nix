{ lib, config, pkgs, flake, ... }:
with lib;
let
  name = "k3s";
  cfg = config.services.${name};
in
{
  imports = [
    flake.inputs.hardware.nixosModules.raspberry-pi-4
  ];

  config = mkIf cfg.enable {
    boot = {
      kernelParams = [
        "cgroup_memory=1"
        "cgroup_memory=1"
        "cgroup_enable=memory"
      ];
    };

    networking.firewall = mkIf (cfg.role == "server") {
      allowedTCPPorts = [ 6443 ];
    };

    # boot.growPartition = true;

    services = {
      k3s = {
        extraFlags = toString [
          "--disable-helm-controller"
          "--disable-cloud-controller"
          "--disable-network-policy"
          "--disable traefik"
          "--disable local-storage"
          # coredns, servicelb, metrics-server
        ];
        tokenFile = flake.lib.pass "k3s";
        serverAddr = "https://k.bryton.io:6443";
      };
    };
    environment.systemPackages = with pkgs; [ libcgroup k3s ];
  };
}
