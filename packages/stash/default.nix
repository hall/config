{ pkgs
, lib
, stdenv
, fetchurl
, autoPatchelfHook
, openssl
, ffmpeg
, sqlite
, makeWrapper
}:
stdenv.mkDerivation rec {
  name = "stash-bin";
  version = "0.27.0";

  executable = fetchurl {
    hash = "sha256-1M32AKWz0ViobVnoZjsfXRW1aBI+WnudKh6wPFDOLcc=";
    url = "https://github.com/stashapp/stash/releases/download/v${version}/stash-linux";
    executable = true;
  };

  dontUnpack = true;

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    ffmpeg
    openssl
    sqlite
    makeWrapper
    (pkgs.python3.withPackages (p: with p; [ requests configparser progressbar cloudscraper ]))
  ];

  installPhase = ''
    mkdir -p $out/bin
    makeWrapper "${executable}" "$out/bin/stash" \
      --prefix PATH ":" "${lib.makeBinPath [ ffmpeg ]}"
  '';

  meta = with lib; {
    description = "An organizer for your porn, written in Go";
    license = licenses.agpl3Plus;
    homepage = "https://stashapp.cc";
    # maintainers = with lib.maintainers; [ airradda ];
    platforms = [ "x86_64-linux" ];
  };
}
