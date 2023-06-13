{ kubenix, flake, vars, lib, ... }:
let
  # TODO: replace with an upstream function
  # merge a list of sets https://stackoverflow.com/a/54505212
  recursiveMerge = with builtins; attrList:
    let f = attrPath:
      zipAttrsWith (n: values:
        if tail values == [ ]
        then head values
        else if all isList values
        then unique (concatLists values)
        else if all isAttrs values
        then f (attrPath ++ [ n ]) values
        else elemAt values ((length values) - 1)
      );
    in f [ ] attrList;

  config = with builtins; with lib.attrsets; mapAttrs'
    (f: v: nameValuePair
      # volume names cannot contain a period
      (builtins.replaceStrings [ "." ] [ "a--" ] f)
      (vars.config v))
    (recursiveMerge (attrValues (mapAttrs
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
