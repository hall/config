{ config, lib, pkgs, flake, ... }:
let
  name = "registry";
  cfg = config.${name};
in
{
  options.${name} = {
    enable = lib.mkEnableOption "docker registry";
  };
  config = lib.mkIf cfg.enable {

    networking.firewall.allowedTCPPorts = [ config.services.dockerRegistry.port ];

    services.dockerRegistry = {
      enable = true;
      enableGarbageCollect = true;
      garbageCollectDates = "monthly";
      listenAddress = "0.0.0.0";
      extraConfig = {
        proxy.remoteurl = "https://registry-1.docker.io";
      };
    };
  };
}
