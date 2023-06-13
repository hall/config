{ config, lib, pkgs, kubenix, ... }: with lib; {
  submodules.imports = [{
    module = { name, config, ... }:
      let cfg = config.submodule.args; in
      {
        imports = with kubenix.modules; [
          helm
          k8s
          submodule
        ];

        options.submodule.args = {
          enable = mkEnableOption "a simple and generic helm release template";

          namespace = mkOption {
            default = "default";
            type = types.str;
            description = "target namespace";
          };

          image = mkOption {
            type = types.str;
            description = "image name with tag";
          };

          host = mkOption {
            type = types.str;
            default = "";
            description = "hostname subdomain";
          };

          port = mkOption {
            type = types.int;
            default = 80;
            description = "container port";
          };

          persistence = mkOption {
            description = "attrset of persistent volumes";
            default = { };
            type = types.attrsOf
              (types.submodule
                ({ config, ... }: {
                  options = {
                    enabled = mkOption {
                      type = types.bool;
                      default = true;
                    };
                    size = mkOption {
                      type = types.str;
                      default = "1Gi";
                    };
                    accessMode = mkOption {
                      type = types.str;
                      default = "ReadWriteOnce";
                    };
                    storageClass = mkOption {
                      type = types.str;
                      default = "longhorn-static";
                    };
                    mountPath = mkOption {
                      type = types.str;
                      default = "/${config._module.args.name}";
                    };
                    existingClaim = mkOption {
                      type = types.str;
                      default = "";
                    };
                    type = mkOption {
                      type = types.str;
                      default = "";
                    };
                    hostPath = mkOption {
                      type = types.str;
                      default = "";
                    };

                    # TODO: only used by esphome
                    name = mkOption {
                      type = types.str;
                      default = "";
                    };
                    readOnly = mkOption {
                      type = types.bool;
                      default = false;
                    };
                    subPath = mkOption {
                      type = types.str;
                      default = "";
                    };
                  };
                }));
          };

          config =
            mkOption
              {
                type = types.attrs;
                default = { };
                description = "yaml in configmap";
              };

          values = mkOption {
            type = types.attrs;
            default = { };
            description = "freeform release values";
          };
        };

        config = {
          submodule = {
            name = "release";
            passthru.kubernetes.objects = config.kubernetes.objects;
          };

          kubernetes.helm.releases.${config._module.args.name} = {
            inherit (cfg) namespace;
            chart = kubenix.lib.helm.fetch {
              repo = "http://bjw-s.github.io/helm-charts/";
              chart = "app-template";
              version = "1.5.1";
              sha256 = "oIiBbYBcDlrg6LHXo38jg83s0BvSfo6rlvea2WASl54=";
            };
            values =
              let
                img = builtins.split ":" cfg.image;
                repo = builtins.split "/" (builtins.elemAt img 0);
                name = builtins.elemAt repo ((builtins.length repo) - 1);
              in
              lib.mkMerge [
                {
                  inherit (cfg) persistence;
                  image = {
                    repository = builtins.elemAt img 0;
                    tag = builtins.elemAt img 2;
                  };
                  service.main.ports.http.port = cfg.port;
                  ingress.main = {
                    enabled = cfg.host != "";
                    hosts = [{
                      host = "${cfg.host}.bryton.io"; # {flake.lib.hostname}";
                      paths = [{ path = "/"; }];
                    }];
                  };
                }
                (mkIf (cfg.config != { }) {
                  persistence.config = {
                    enabled = true;
                    type = "configMap";
                    name = "${name}-config";
                    readOnly = true;
                  };
                  configMaps.config = {
                    enabled = true;
                    data."config.yml" = builtins.readFile ((pkgs.formats.yaml { }).generate "." cfg.config);
                  };
                })
                cfg.values
              ];
          };
        };
      };
  }];
}
