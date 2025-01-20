{ python310Packages
, rustPlatform
, fetchFromGitHub
, ...
}:
with python310Packages;
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
                (jupyterlab.overrideAttrs (prev: {
                  src = fetchPypi {
                    pname = "jupyterlab";
                    version = "3.4.8";
                    sha256 = "sha256-H6+4tlcAXZFgPzw639bZ6OrzP9xgFTf+8JKDMy7+Z8s=";
                  };
                }))
                (
                  buildPythonPackage rec {
                    pname = "ipywidgets";
                    version = "7.7.1";
                    format = "setuptools";

                    src = fetchPypi {
                      inherit pname version;
                      hash = "sha256-Xy+ht6+uGvMsiAiMmCitl43pPd2jk9ftQU5VP+6T3Ks=";
                    };

                    propagatedBuildInputs = [
                      ipython
                      ipykernel
                      jupyterlab-widgets
                      traitlets
                      nbformat

                      notebook
                      (widgetsnbextension.overrideAttrs (prev: {
                        src = fetchPypi {
                          version = "3.6.0";
                          pname = "widgetsnbextension";
                          hash = "sha256-6Ep6n8ubrz1XEG4YSnOJqPjrk1v3QaXrnWCqGMwCmoA=";
                        };
                        buildInputs = prev.buildInputs ++ [
                          notebook
                        ];
                      }))
                    ];
                    doCheck = false;
                    # checkInputs = [ pytestCheckHook ]; # fails
                  }
                )
              ];
            }
          )

        ];
      }
    )
    (
      buildPythonPackage rec {
        pname = "minify_html";
        version = "0.10.7";
        format = "wheel";
        # TODO: error: cannot download minify_html-0.10.7-cp310-cp310-manylinux_2_27_x86_64.whl from any mirror
        # src = fetchPypi {
        #   inherit pname version format;
        #   sha256 = "sha256-LIcC1O2o2qY04JjYmGy6HF+AsUUu0WvweIxty6y1P5I=";
        #   python = "cp310";
        #   abi = "cp310";
        #   platform = "manylinux_2_27_x86_64";
        # };
        src = builtins.fetchurl {
          url = "https://files.pythonhosted.org/packages/48/aa/4edf558aa0ce181e6dcb5976bf05dc7770d53a4c330046d7b65e5c559e8e/minify_html-0.10.7-cp310-cp310-manylinux_2_27_x86_64.whl";
          sha256 = "sha256:1nqspn380pwl4gqwdkww17zhq7gabslsmk948ykgkh3b6ghilsn7";
        };
        doCheck = false;
      }
    )
  ];
}
