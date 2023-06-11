{ flake, ... }: {
  imports = [ flake.inputs.hardware.nixosModules.raspberry-pi-4 ];
  services.k8s = {
    enable = true;
    config = {
      node-label = [
        "${flake.lib.hostname}/ups=true"
      ];
    };
  };

}
