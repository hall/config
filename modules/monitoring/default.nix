{ config, lib, ... }:
with lib; {
  options.monitoring = {
    enable = mkEnableOption (mdDoc "monitoring");
  };
  config = {
    systemd.services.alloy.serviceConfig.EnvironmentFile = config.age.secrets.grafana.path;
    # changes done in the grafana cloud console
    #  - connections: linux-node, postgres, hass
    services.alloy = {
      enable = true;
      extraFlags = [
        # TODO: throws TLS errors b/c its getting the wrong/local cert
        "--disable-reporting"
      ];
    };
    environment.etc = with builtins; listToAttrs
      (map
        (path: {
          name = "alloy/${path}";
          value.source = ./alloy/${path};
        })
        (attrNames (readDir ./alloy))
      ) // {
      "alloy/nixos.alloy".text = ''
        prometheus.scrape "nixos" {
          forward_to = [prometheus.remote_write.default.receiver]
          targets = [
            ${concatStringsSep "" (map (exporter: ''
              {"__address__" = "localhost:${toString exporter.port}"},
            '')
            (attrValues (lib.filterAttrs (k: v: v.enable) 
            (removeAttrs config.services.prometheus.exporters ["assertions" "warnings" "minio" "unifi-poller" "tor"])
            ))
            )}
          ]
        }
      '';
    };
    # services.prometheus.exporters = {
    #   # zfs
    #   # wireguard
    #   # unifi
    #   # systemd
    #   # sql
    #   # nut
    #   # node
    #   # nginx
    #   # exportarr
    # };
  };
}
