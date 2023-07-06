{ kubenix, pkgs, lib, flake, ... }: {
  imports = with kubenix.modules; [
    helm
    k8s
    submodules
    ./_modules/release.nix
  ];
  config = lib.mkMerge ([{
    kubernetes = {
      kubeconfig = "/run/secrets/kubeconfig";
      version = "1.26";
      resources.namespaces.default.metadata.labels = {
        "goldilocks.fairwinds.com/enabled" = "true";
        "goldilocks.fairwinds.com/vpa-update-mode" = "auto";
      };
    };
  }] ++ (builtins.map
    (f: import ./${f} {
      inherit kubenix flake lib pkgs;
      vars = {
        secret = val: "ref+file:///run/secrets/kubenix#${val}+";
        yaml = y: builtins.readFile ((pkgs.formats.yaml { }).generate "." y);
        json = y: builtins.readFile ((pkgs.formats.json { }).generate "." y);
        config = cfg: builtins.readFile (pkgs.runCommand "configuration.yaml" { preferLocalBuild = true; } ''
          cp ${(pkgs.formats.yaml {}).generate "configuration.yaml" (cfg)} $out
          sed -i -e "s/'\!\([a-z_]\+\) \(.*\)'/\!\1 \2/;s/^\!\!/\!/;" $out
        '');
      };
    })
    (builtins.filter
      (f: (f != "default.nix")
        && (!lib.strings.hasPrefix "_" f)
        && ((lib.strings.hasSuffix ".nix" f) || (!lib.strings.hasInfix "." f))
      )
      (builtins.attrNames (builtins.readDir ./.))
    )
  ));
}
