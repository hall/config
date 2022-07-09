{ lib, flake, pkgs, config, ... }:
{
  imports = [
    flake.inputs.hardware.nixosModules.raspberry-pi-4
  ];

  boot = {
    kernelParams = [
      "cgroup_memory=1"
      "cgroup_memory=1"
      "cgroup_enable=memory"
    ];
  };

  networking.firewall = {
    allowedTCPPorts = [ 6443 ];
  };

  # boot.growPartition = true;

  services = {
    k3s = {
      enable = true;
      # role = "server";
      # services.k3s.extraFlags = toString [
      #   "--kubelet-arg=v=4"
      # ];
    };
  };
  environment.systemPackages = with pkgs; [ libcgroup k3s ];

}
