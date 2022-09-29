{ lib
, stdenv
, faust2jack
, pkg-config
, libmicrohttpd
, makeDesktopItem
}:
let
  titleCase = str:
    let
      first = (builtins.substring 0 1 str);
      rest = (builtins.substring 1 (builtins.stringLength str) str);
    in
    "${(lib.strings.toUpper first)}${rest}";

  name = "effects";
  desktop = makeDesktopItem {
    name = name;
    exec = name;
    desktopName = titleCase name;
    icon = ./${name}.svg;
    categories = [ "Audio" ];
  };
in
stdenv.mkDerivation rec {
  inherit name;
  src = [
    ./main.dsp
  ];

  unpackPhase = ''
    for file in $src; do
        cp $file "$(stripHash $file)"
    done
  '';

  buildPhase = ''
    faust2jack -httpd -osc main.dsp
  '';

  installPhase = ''
    mkdir -p $out/{bin,lib}
    cp main $out/bin/${name}

    runHook postInstall
  '';

  postInstall = ''
    mkdir -p $out/share
    cp -r ${desktop}/share/applications $out/share

  '';

  nativeBuildInputs = [
    pkg-config
    libmicrohttpd
    faust2jack
  ];

  meta = with lib; {
    #   description = "";
    #   homepage = "";
    #   license = licenses.gpl3Plus;
    #   maintainers = with maintainers; [  ];
    platforms = [ "x86_64-linux" "aarch64-linux" ];
  };
}
