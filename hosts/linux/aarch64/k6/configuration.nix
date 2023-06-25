{ flake, modulesPath, ... }: {
  imports = [
    flake.inputs.hardware.nixosModules.raspberry-pi-4
    (modulesPath + "/installer/sd-card/sd-image-aarch64.nix")
  ];
  services.k8s.enable = true;
}
