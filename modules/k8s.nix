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
      default = "agent";
      type = lib.types.str;
    };
    config = lib.mkOption {
      description = "extra configuration options";
      default = { };
      type = lib.types.attrs;
    };

  };
  config = mkIf cfg.enable {

    boot.kernelParams = [
      "cgroup_memory=1"
      "cgroup_enable=memory"
      "cgroup_enable=cpuset"
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
        tokenFile = "/run/secrets/k3s";
        clusterInit = mkIf (config.networking.hostName == "k0") true;
        serverAddr =
          # TODO: auto ignore on k0 bootstrap
          # mkIf (config.networking.hostName != "k0")
          "https://k:6443";
      };
      openiscsi = {
        enable = true;
        name = "longhorn";
      };
    };
    environment = {
      etc = {
        "rancher/k3s/registries.yaml".text = builtins.toJSON {
          mirrors."docker.io".endpoint = [
            "http://registry:5000"
          ];
        };
        "rancher/k3s/config.yaml.d/custom.yaml".text = builtins.toJSON cfg.config;
        "rancher/k3s/config.yaml" = mkIf (cfg.role == "server") {
          text = builtins.toJSON {
            tls-san = [ "k" ];
            flannel-backend = "wireguard-native";
            disable = [
              "traefik"
              "local-storage"
            ];
            disable-helm-controller = true;
            disable-cloud-controller = true;
            etcd-expose-metrics = true;
          };
        };
      };
      systemPackages = with pkgs; [
        libcgroup
        usbutils

        # longhorn
        cryptsetup # encryption
        nfs-utils # RWX
        openiscsi
      ];
    };

    age.secrets.k3s.file = ../secrets/k3s.age;

    # each node has a single 1TB SSD attached over USB
    # disko.devices.disk.sda = {
    #   device = "/dev/sda";
    #   type = "disk";
    #   content = {
    #     type = "table";
    #     format = "gpt";
    #     partitions = [{
    #       name = "root";
    #       part-type = "primary";
    #       bootable = true;
    #       start = "1M";
    #       end = "100%";
    #       content = {
    #         type = "filesystem";
    #         format = "ext4";
    #         mountpoint = "/";
    #       };
    #     }];
    #   };
    # };

    # TODO: implement ephemeral storage with persistent mount
    # environment.persistence."/persistent" = {
    #   hideMounts = true;
    #   directories = [
    #     "/var/lib/cni"
    #     "/var/lib/kubelet"
    #     "/var/lib/longhorn"
    #     "/var/lib/rancher/k3s"
    #     "/var/log/containers"
    #     "/var/log/journal"
    #     "/var/log/pods"
    #   ];
    # };

    # TODO: undo temp symlinks for longhorn
    # https://github.com/longhorn/longhorn/issues/2166
    system.activationScripts.longhorn.text = ''
      for app in bash flock stat lsblk mount iscsiadm; do
        ln -fs /run/current-system/sw/bin/$app /bin/$app
      done
    '';

  };
}
