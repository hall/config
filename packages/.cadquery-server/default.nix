{ python313Packages
, fetchFromGitHub
, ...
}:
with python313Packages;
buildPythonPackage rec {
  pname = "cadquery-server";
  version = "0.4.1";
  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-3pkvU70T3q3icIypA7vXIJznK+tDJYM/zMX8GavcsbQ=";
  };
  doCheck = false;
  buildInputs = [
    cairosvg
    flask
    matplotlib
    minify_html
    (
      buildPythonPackage rec {
        pname = "cadquery-massembly";
        version = "0.9.0";
        src = fetchFromGitHub {
          owner = "bernhard-42";
          repo = pname;
          rev = "v${version}";
          sha256 = "sha256-wxWI02VgqsDEqPq4pYpj8jI5CVkHm36OuGXiee2xV5w=";
        };
        doCheck = false;
      }
    )
    (
      buildPythonPackage rec {
        pname = "jupyter-cadquery";
        version = "3.2.2";
        src = fetchFromGitHub {
          owner = "bernhard-42";
          repo = pname;
          rev = "v${version}";
          sha256 = "sha256-kAVuNFG+6euhwvHfPZ11aMvYs3Rl5F4A37mOrHSeawA=";
        };
        doCheck = false;
        buildInputs = [
          (
            buildPythonPackage rec {
              pname = "cad_viewer_widget";
              version = "1.3.5";
              # format = "wheel";
              src = fetchPypi {
                inherit pname version;
                sha256 = "sha256-0wpkKkuekDS2UD16wVTtV2lRXGq3D2paKXRFVC3SjqE=";
              };
              doCheck = false;
              buildInputs = [
                jupyter-packaging
                numpy
                jupyterlab
                ipywidgets
              ];
            }
          )
        ];
      }
    )
  ];
}
