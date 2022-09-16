{ evalModules, flake, lib }:
let
  # merge a list of sets
  # https://stackoverflow.com/a/54505212
  recursiveMerge = with builtins; attrList:
    let f = attrPath:
      zipAttrsWith (n: values:
        if tail values == [ ]
        then head values
        else if all isList values
        then unique (concatLists values)
        else if all isAttrs values
        then f (attrPath ++ [ n ]) values
        else lib.lists.last values
      );
    in f [ ] attrList;

  # a generic chart
  template = { kubenix }: kubenix.lib.helm.fetch {
    repo = "http://bjw-s.github.io/helm-charts/";
    chart = "app-template";
    version = "0.1.1";
    sha256 = "sha256-Xu8c/gK7sPvlk/LY1QKjoX3xmH3amOy/dN4zbi3CyTM=";
  };
  /*
    A simple setup which abstracts most common things
  */
  simple =
    { kubenix
    , image
    , port
    , config ? { }
    , persistence ? { }
    }:
    let
      img = builtins.split ":" image;
      repo = builtins.split "/" (builtins.elemAt img 0);
      name = builtins.elemAt repo ((builtins.length repo) - 1);
    in
    {
      helm.releases.${name} = {
        chart = template { inherit kubenix; };
        namespace = "default";
        values = {
          image = {
            repository = builtins.elemAt img 0;
            tag = builtins.elemAt img 2;
          };
          service.main.ports.http.port = port;
          ingress.main = {
            enabled = true;
            hosts = [{
              host = "${name}.${flake.hostname}";
              paths = [{ path = "/"; }];
            }];
          };
          persistence = builtins.mapAttrs
            (k: v: {
              enabled = true;
              size = if builtins.hasAttr "size" v then v.size else "1Gi";
              accessMode = "ReadWriteOnce";
              storageClass = "longhorn-static";
            } // v)
            persistence;
        };

      };
    };
in
evalModules {
  module = { kubenix, lib, pkgs, age, ... }: {
    imports = with kubenix.modules; [ helm ];
    kubenix.project = "k";
    kubernetes = recursiveMerge ([
      {
        kubeconfig = "/run/secrets/kubeconfig";
      }
    ] ++ (builtins.map
      (f: import ./${f} {
        inherit kubenix flake lib pkgs;
        vars = {
          inherit template simple;
          secret = val: "ref+file:///run/secrets/kubenix#${val}+";
        };
      })
      (builtins.filter (f: (f != "default.nix") && (!lib.strings.hasPrefix "_" f))
        (builtins.attrNames (builtins.readDir ./.))
      )
    ));
  };
}
