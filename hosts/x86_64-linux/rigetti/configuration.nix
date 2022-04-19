{ pkgs, ... }:
{
  imports = [
    ./hardware.nix
  ];

  networking = {
    # firewall = {
    #   allowedTCPPorts = [
    #   ];
    # };
  };

}
