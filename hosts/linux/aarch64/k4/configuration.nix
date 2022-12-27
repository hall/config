{ flake, ... }:
{
  imports = [
    flake.inputs.hardware.nixosModules.raspberry-pi-4
  ];

  services.k8s = {
    enable = true;
    role = "agent";
  };

  # k label node k4 bryton.io/ups=true
}
