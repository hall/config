{ config, lib, ... }:
with lib; {
  options.monitoring = {
    enable = mkEnableOption (mdDoc "monitoring");
  };
  config = {
    systemd.services.alloy.serviceConfig.EnvironmentFile = config.age.secrets.grafana.path;
    # changes done in the grafana cloud console
    #  - /connections/add-new-connection/linux-node
    #  - /connections/add-new-connection/hass
    services.alloy = {
      enable = true;
      extraFlags = [
        # TODO: throws TLS errors b/c its getting the wrong/local cert
        "--disable-reporting"
      ];
    };
    environment.etc = with builtins; listToAttrs (map
      (path: {
        name = "alloy/${path}";
        value.source = ./alloy/${path};
      })
      (attrNames (readDir ./alloy))
    );
  };
}
