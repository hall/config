{ stdenv
, gfortran
, xorg
, libGL
, expat
, zlib
, writeShellScriptBin
, lib
, mkShell
, freecad
  # , flake
, fetchFromGitHub
, python3Packages
, python3
, ...
}:
let
  libs = [
    stdenv.cc.cc
    gfortran.cc.lib
    xorg.libX11
    libGL
    expat
    zlib
  ];
in
# poetry2nix.mkPoetryApplication {
  #   projectDir = fetchFromGitHub {
  #     repo = "cadquery-server";
  #     owner = "roipoussiere";
  #     rev = "0.4.1";
  #     sha256 = "hFfJt5LDjp1MEgrwLepoUAdAKrziBKfi44tgmnvdcAU=";
  #   };
  # }

  # (import flake.inputs.mach {
  #   inherit (flake.inputs.nixpkgs.legacyPackages.x86_64-linux) pkgs;
  #   python = "python39";
  #   pypiDataRev = "master";
  #   pypiDataSha256 = "0dmfbnd17j69vhkdxjfp0dd87nj0bx6b4v0lpwnj6n7g4ibvmyr0";
  # }).mkPython {
  #   requirements = ''
  #     # cadquery-server[cadquery]
  #     cadquery-ocp==7.6.3
  #   '';
  # }

  # TODO: do betta
with python3Packages; buildPythonPackage {
  name = "cad";
  src = ./.;
  buildInputs = [
    (python3.withPackages (p: with p; [
      autopep8
    ]))
    pip
    (writeShellScriptBin "cad" ''
      cq-server run --ui-theme dark $@
    '')
  ];
  shellHook = ''
    # Tells pip to put packages into $PIP_PREFIX instead of the usual locations.
    # See https://pip.pypa.io/en/stable/user_guide/#environment-variables.
    export PIP_PREFIX=$(pwd)/_build/pip_packages
    export PYTHONPATH="$PIP_PREFIX/${python3.sitePackages}:$PYTHONPATH"
    export PATH="$PIP_PREFIX/bin:$PATH"
    unset SOURCE_DATE_EPOCH

    export LD_LIBRARY_PATH=${lib.makeLibraryPath libs}

    pip install \
        cadquery-server \
        cadquery==2.2.0b2 \
        cqkit==0.4.0
  '';
}
