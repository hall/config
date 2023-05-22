{ stdenv
, fetchFromGitHub
, qmk
, rsync
, bash
}:
let
  keymap = "hall";
  keyboard = "bastardkb/charybdis/3x5/v1/elitec";
in
stdenv.mkDerivation rec {
  name = "keyboard";
  src = fetchFromGitHub {
    owner = "qmk";
    repo = "qmk_firmware";
    rev = "0.19.10";
    sha256 = "sha256-BoeBX00JHX+Vf7d0PtA0G2cilh57Mg3um2PbBSmdUic=";
    fetchSubmodules = true;
  };

  patches = [ ./keyboards ];
  patchPhase = ''
    ${rsync}/bin/rsync -a $patches/ keyboards
  '';

  buildPhase = ''
    export SKIP_VERSION=1 # git is not available
    QMK_HOME=$PWD ${qmk}/bin/qmk compile -kb ${keyboard} -km ${keymap}
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp *.hex $out/

    # doing this instead of writeShellScriptBin to access $out
    cat <<EOF> $out/bin/${name}
    #!${bash}/bin/bash
    QMK_HOME=${src} ${qmk}/bin/qmk flash $out/*.hex
    EOF

    chmod +x $out/bin/${name}
  '';

  dontFixup = true;

  meta.platforms = [ "x86_64-linux" ];
}
