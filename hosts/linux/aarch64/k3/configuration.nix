{ flake, ... }:
{
  imports = [
    flake.inputs.hardware.nixosModules.raspberry-pi-4
  ];

  services.k8s = {
    enable = true;
    role = "agent";
  };

  # k label node k3 bryton.io/tpu=true bryton.io/printer=true
}
