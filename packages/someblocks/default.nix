{ lib
, stdenv
, fetchFromSourcehut
, pkg-config
, wayland
, wayland-protocols
, wayland-scanner
, conf ? null
}:

let
  configFile = if lib.isDerivation conf || builtins.isPath conf then conf else "blocks.def.h";
in

stdenv.mkDerivation rec {
  pname = "someblocks";
  version = "1.0.1";

  src = fetchFromSourcehut {
    owner = "~raphi";
    repo = pname;
    rev = version;
    hash = "sha256-pUdiEyhqLx3aMjN0D0y0ykeXF3qjJO0mM8j1gLIf+ww=";
  };

  nativeBuildInputs = [ pkg-config wayland-scanner ];
  buildInputs = [ wayland wayland-protocols ];

  prePatch = ''
    cp ${configFile} blocks.h
  '';

  installPhase = ''
    mkdir -p $out/bin/
    cp someblocks $out/bin/someblocks
  '';

  meta = with lib; {
    homepage = "https://git.sr.ht/~raphi/someblocks";
    description = "moduler status bar for somebar written in c";
    license = licenses.mit;
    # maintainers = with maintainers; [ magnouvean ];
    platforms = platforms.linux;
    mainProgram = "someblocks";
  };
}
