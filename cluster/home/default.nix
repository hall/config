{ kubenix, flake, vars, lib, pkgs, ... }:
let
  configMap = with builtins; dir:
    listToAttrs (map
      (f: {
        # remove absolute path prefix
        name = replaceStrings [ "${toString ./.}/" ".nix" "." "/" ] [ "" "---yaml" "---" "--" ] (toString f);
        # read file
        value =
          if lib.hasSuffix ".nix" f
          then vars.config (import f { inherit flake lib; })
          else readFile f;
      })
      # get list of all files in 'dir`
      (lib.filesystem.listFilesRecursive dir)
    );
in
{
  helm.releases.home-assistant = {
    chart = vars.template { inherit kubenix; };
    namespace = "default";
    values = {
      image = {
        repository = "homeassistant/home-assistant";
        tag = "2023.3";
      };
      service.main.ports.http.port = 8123;
      ingress.main = {
        enabled = true;
        hosts = [{
          host = "home.${flake.hostname}";
          paths = [{ path = "/"; }];
        }];
      };
      persistence = {
        config = {
          enabled = true;
          mountPath = "/config";
          storageClass = "longhorn-static";
        };
        secrets = {
          enabled = true;
          type = "secret";
          subPath = "secrets.yaml";
          mountPath = "/config/secrets.yaml";
          name = "home-assistant";
          readOnly = true;
        };
        configuration = {
          enabled = true;
          type = "configMap";
          mountPath = "/config/configuration.yaml";
          subPath = "configuration.yaml";
          name = "home-assistant-config";
          readOnly = true;
        };
      } // (with builtins; (mapAttrs
        (name: value: {
          enabled = true;
          type = "configMap";
          mountPath = "${builtins.replaceStrings [ "---" "--" ] [ "." "/" ] name}";
          subPath = name;
          name = "home-assistant-config";
          readOnly = true;
        })
        (configMap ./config))
      );

      secret."secrets.yaml" = vars.secret "/home";

      configmap = {
        config = {
          enabled = true;
          data = (configMap ./config) // {
            "configuration.yaml" = vars.config (import ./configuration.nix { inherit flake vars; });
          };
        };
      };
    };
  };
}
