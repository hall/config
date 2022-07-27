{ pkgs ? import <nixpkgs> { } }:
let
  mach-nix = import
    (builtins.fetchGit {
      url = "https://github.com/DavHau/mach-nix";
    })
    {
      condaChannelsExtra.cadquery = [
        (builtins.fetchurl "https://conda.anaconda.org/cadquery/linux-64/repodata.json")
      ];
    };
  py = mach-nix.mkPython rec {

    requirements = ''
      # jupyterlab
      # cadquery
      # conda
    '';

    providers = {
      _default = "cadquery,conda-forge,conda,wheel,sdist,nixpkgs";
    };

  };
in
mach-nix.nixpkgs.mkShell {
  buildInputs = with pkgs; [
    py
    conda
  ];
  shellHook = ''
    conda-shell
    conda install -y -c conda-forge -c cadquery python=3.8 cadquery=2 jupyter_cadquery
    pip install jupyter-cadquery==2.2.1 matplotlib
  '';
}
