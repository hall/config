{ config, lib, pkgs, flake, ... }:
let
  name = "hyperion";
  cfg = config.${name};
in
{
  options.${name} = {
    enable = lib.mkEnableOption "run hyperion-ng";
  };
  config = lib.mkIf cfg.enable {
    # TODO: remove
    environment.systemPackages = with pkgs; [ hyperion-ng ];
    networking.firewall.allowedTCPPorts = [ 8090 ];
    systemd.user.services.hyperion = {
      enable = true;
      description = "Hyperion ambient light service";
      serviceConfig.user = flake.lib.username;
      documentation = [ "https://docs.hyperion-project.org" ];
      # requisite = [ "network.target" ];
      wants = [ "network-online.target" ];
      after = [
        "network-online.target"
        "systemd-resolved.service"
      ];
      wantedBy = [ "multi-user.target" ];
      environment = {
        XDG_RUNTIME_DIR = "/run/user/1000";
        DISPLAY = ":0.0";
      };

      script = "/${pkgs.hyperion-ng}/bin/hyperiond";
    };
  };
}
