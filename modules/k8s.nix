{ lib, config, pkgs, flake, ... }:
with lib;
let
  name = "k8s";
  cfg = config.services.${name};
in
{
  options.services.${name} = {
    enable = lib.mkEnableOption "kubernetes node";
    role = lib.mkOption {
      description = "server or agent node";
      default = "server";
      type = lib.types.str;
    };

  };
  config = mkIf cfg.enable {

    boot.kernelParams = [
      "cgroup_memory=1"
      "cgroup_enable=memory"
    ];

    networking.firewall = {
      allowedUDPPorts = [
        53 # dns
        8472 # cni (flannel vxlan)
      ];
      allowedTCPPorts = [
        4443 # metrics server but shouldn't be necesasry?
        10250 # metrics server
        9100 # ?
      ] ++ (lib.optionals (cfg.role == "server") [
        6443 # k8s api
        2379 # etcd client requests
        2380 # etcd peer communication
      ]);
    };

    services = {
      k3s = {
        enable = true;
        role = cfg.role;
        # TODO: unpin ton 1.24 for longhorn
        package = flake.packages.k3s;
        extraFlags = mkIf (cfg.role == "server") (toString [
          "--tls-san=k"
          "--disable-helm-controller"
          "--disable-cloud-controller"
          "--disable-network-policy"
          "--disable traefik"
          "--disable local-storage"
          # "--disable servicelb"
          # coredns, metrics-server
        ]);
        tokenFile = "/run/secrets/k3s";
        clusterInit = mkIf (config.networking.hostName == "k0") true;
        serverAddr = "https://k:6443";
      };
      openiscsi = {
        enable = true;
        name = "longhorn";
      };
    };
    environment = {
      etc."rancher/k3s/registries.yaml".text = builtins.readFile ((pkgs.formats.yaml { }).generate "." {
        mirrors."docker.io".endpoint = [
          "http://registry:5000"
        ];
      });
      systemPackages = with pkgs; [
        libcgroup
        k3s
        nfs-utils # longhorn RWX
        openiscsi # longhorn
        usbutils
      ];
    };

    fileSystems = {
      "/var/lib/longhorn" = {
        device = "/dev/disk/by-label/storage"; # e2label /dev/sda storage
        fsType = "ext4";
      };
    };

    age.secrets.k3s.file = ../secrets/k3s.age;
  };
}
