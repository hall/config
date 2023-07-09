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
  submodules.instances.home-assistant = {
    submodule = "release";
    args = {
      image = "homeassistant/home-assistant:2023.7.1";
      port = 8123;
      host = "home";

      values = {
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
            name = "home-assistant-secret";
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

        secrets.secret = {
          enabled = true;
          stringData."secrets.yaml" = vars.secret "/home";
        };

        configMaps.config = {
          enabled = true;
          data = (configMap ./config) // {
            "configuration.yaml" = vars.config (import ./configuration.nix { inherit flake vars; });
          };
        };
      };
    };
  };
}
