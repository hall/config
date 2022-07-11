{ stdenv, dpkg, glibc, gcc-unwrapped, autoPatchelfHook, zlib, makeWrapper, hexdump, xxd }:
stdenv.mkDerivation {
  name = "crowdstrike";
  system = "x86_64-linux";
  src = ./falcon-sensor.deb;
  # src = https://drive.google.com/file/d/1xUC55drHC24JV5V14lnkRHDxwt33DY8U/view?usp=sharing;

  # Required for compilation
  nativeBuildInputs = [
    autoPatchelfHook # Automatically setup the loader, and do the magic
    dpkg
    zlib
    makeWrapper
    hexdump
    xxd
  ];

  # Required at running time
  buildInputs = [
    glibc
    gcc-unwrapped
  ];

  unpackPhase = "true";

  # Extract and copy executable in $out/bin
  installPhase = ''
    set -x
    mkdir -p $out/{bin,var/log}
    dpkg -x $src $out
    # mkdir -p $out/opt/CrowdStrike/falconstore
    # makeWrapper $out/opt/CrowdStrike/falconctl $out/opt/CrowdStrike/falconctl-wrapped --run 'cd $out/'
    ln -s $out/opt/CrowdStrike/falconctl $out/bin/falconctl
    ln -s $out/opt/CrowdStrike/falcond $out/bin/falcond
  '';

  postBuild = '''';
}
