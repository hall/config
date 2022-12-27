{ flake, lib, pkgs, ... }:
{
  imports = [
    flake.inputs.hardware.nixosModules.raspberry-pi-4
  ];

  services.k8s.enable = true;
}
