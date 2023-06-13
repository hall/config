{ kubenix, flake, vars, lib, ... }:
let
  config = with builtins; with lib.attrsets; mapAttrs'
    (f: v: nameValuePair
      # volume names cannot contain a period
      (builtins.replaceStrings [ "." ] [ "a--" ] f)
      (vars.config v))
    (flake.lib.recursiveMerge (attrValues (mapAttrs
      (f: v: (import ./${f} { inherit flake; }))
      (removeAttrs (readDir ./.) [ "default.nix" ]))));
in
{
  submodules.instances.esphome = {
    submodule = "release";
    args = {

      image = "esphome/esphome:2022.11";
      port = 6052;
      persistence = {
        data = {
          size = "5Gi";
          mountPath = "/config";
        };
        secrets = {
          enabled = true;
          type = "secret";
          subPath = "secrets.yaml";
          mountPath = "/config/secrets.yaml";
          name = "home-assistant-secret";
          readOnly = true;
        };
      }
      // (with builtins; (mapAttrs
        (name: value: {
          enabled = true;
          type = "configMap";
          mountPath = "/config/${builtins.replaceStrings [ "a--" ] [ "." ] name}.yaml";
          subPath = name;
          name = "esphome-config";
          readOnly = true;
        })
        config)
      );
      values = {
        env.ESPHOME_DASHBOARD_USE_PING = true;
        configMaps.config = {
          enabled = true;
          data = config;
        };
      };
    };
  };
}
