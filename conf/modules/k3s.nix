{ lib, config, pkgs, flake, ... }:
with lib;
let
  name = "k3s";
  cfg = config.services.${name};
in
{
  config = mkIf cfg.enable {
    boot = {
      growPartition = true;
      kernelParams = [
        "cgroup_memory=1"
        "cgroup_memory=1"
        "cgroup_enable=memory"
      ];
    };

    networking.firewall.allowedTCPPorts = [
      10250 # metrics server
    ] ++ (lib.optionals (cfg.role == "server") [
      6443 # k8s
      2379 # etcd client requests
      2380 # etcd peer communication
    ]);

    services = {
      k3s = {
        extraFlags = mkIf (cfg.role == "server") (toString [
          "--disable-helm-controller"
          "--disable-cloud-controller"
          "--disable-network-policy"
          "--disable traefik"
          "--disable local-storage"
          # coredns, servicelb, metrics-server
        ]);
        tokenFile = "/run/secrets/k3s";
        serverAddr = "https://k0:6443";
      };
      openiscsi = {
        enable = true;
        name = "longhorn";
      };
    };
    environment.systemPackages = with pkgs; [
      libcgroup
      k3s
      nfs-utils # longhorn RWX
    ];

    fileSystems = {
      "/var/lib/longhorn" = {
        device = "/dev/disk/by-label/storage"; # e2label /dev/sda storage
        fsType = "ext4";
      };
    };

    age.secrets.k3s.file = ../secrets/k3s.age;

  };
}
