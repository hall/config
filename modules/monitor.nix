{ config, lib, pkgs, flake, ... }:
let
  name = "monitor";
  cfg = config.${name};
in
{
  options.${name} = {
    enable = lib.mkEnableOption "monitor node";
  };
  config = lib.mkIf cfg.enable {
    services.prometheus.exporters.node = {
      enable = true;
      openFirewall = true;
      enabledCollectors = [
        "systemd"
        "processes"
      ];
    };
  };
}
