{ lib
, stdenv
, fetchFromGitHub
, meson
, ninja
, gettext
, glib
, python3
, pkg-config
, appstream-glib
, wrapGAppsHook
, desktop-file-utils
}:
let
  gatt = python3.pkgs.buildPythonPackage rec {
    pname = "gatt";
    version = "0.2.6";
    src = python3.pkgs.fetchPypi {
      inherit pname version;
      hash = "sha256-BJKZ2zmtfCi7MP41ShUGs7ipmAvnuMQjQRNxlT4WQ/o=";
    };
    doCheck = false;
  };
in
python3.pkgs.buildPythonApplication rec {
  pname = "siglo";
  version = "0.9.8";
  format = "other";

  src = fetchFromGitHub {
    owner = "theironrobin";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-GX1mOJGAF6N4IDT3tWkrgJftp07jZB+EZG9kyNFv2aE=";
  };

  nativeBuildInputs = [
    meson
    ninja
    gettext
    pkg-config
    glib
    desktop-file-utils
    appstream-glib
    wrapGAppsHook
  ];

  propagatedBuildInputs = with python3.pkgs; [
    gatt
    dbus-python
    pygobject3
    requests
  ];

  patches = [ ./systemd.patch ];
  doCheck = false;
  strictDeps = false;

  # mesonFlags = [
  #   "-Dsystemddir=${placeholder "out"}/share/systemd"
  # ];

  preConfigure = ''
    patchShebangs build-aux/meson/postinstall.py
  '';

  meta = with lib; {
    description = "GTK app to sync InfiniTime watch with PinePhone";
    homepage = "https://github.com/theironrobin/siglo";
    # maintainers = with maintainers; [ ];
    license = licenses.mpl20;
    platforms = platforms.linux;
  };
}
