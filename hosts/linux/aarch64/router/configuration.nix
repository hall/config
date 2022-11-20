{ pkgs, flake, lib, ... }: {

  imports = [ flake.inputs.hardware.nixosModules.raspberry-pi-4 ];

  router = {
    enable = true;
    internal = "eth0";
    external = "enp1s0u2";
    # wireless = "wlo1";
  };

  # environment = {
  #   systemPackages = with pkgs; [
  #   ];
  # };

}
