{
  description = "home cluster";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/21.11";
    utils.url = "github:numtide/flake-utils";
    mach.url = "github:DavHau/mach-nix";
  };

  outputs = inputs@{ self, ... }:
    inputs.utils.lib.eachDefaultSystem (system:
      let
        pkgs = inputs.nixpkgs.legacyPackages.${system};
        py = inputs.mach.lib.${system}.mkPython {
          requirements = ''
            jinja2
            kubernetes
            pandas
            # platformio
          '';
        };
      in
      {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            py
            helmfile
            kubernetes-helm
            kustomize
            kubectl
            inotify-tools
            esphome
            velero
          ];

          KUBECONFIG = ~/.kube/k.yaml;

          shellHook = ''
            set -o pipefail
            alias k=kubectl
            helm plugin install https://github.com/aslafy-z/helm-git --version 0.11.1
            helm plugin install https://github.com/databus23/helm-diff
            bw logout
            set -e
            export BW_SESSION=$(bw login --raw)
            set +e
          '';
        };
      });
}
