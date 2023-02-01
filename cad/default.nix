{ stdenv
, gfortran
, xorg
, libGL
, expat
, zlib
, python3
, python3Packages
, writeShellScriptBin
, lib
, mkShell
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
mkShell {
  buildInputs = [
    (python3.withPackages (p: with p; [
      autopep8
    ]))
    python3Packages.pip
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
