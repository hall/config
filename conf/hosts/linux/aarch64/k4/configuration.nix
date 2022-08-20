{ flake, ... }:
{
  imports = [
    flake.inputs.hardware.nixosModules.raspberry-pi-4
  ];

  services.k3s = {
    enable = true;
    role = "agent";
  };
}