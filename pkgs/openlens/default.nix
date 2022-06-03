{ lib, fetchurl, appimageTools, wrapGAppsHook }:

let
  pname = "openlens";
  version = "5.5.3";
  build = "${version}-latest.20220120.1";
  name = "${pname}-${version}";

  src = fetchurl {
    url = "https://github.com/MuhammedKalkan/OpenLens/releases/download/v${version}/OpenLens-${version}.AppImage";
    sha256 = "sha256-4xZfB9fnwwirPeTlcps1bUN+NEI1X9X5v9EIvBlkcJE=";
    name = "${name}.AppImage";
  };

  appimageContents = appimageTools.extractType2 {
    inherit name src;
  };

in
appimageTools.wrapType2 {
  inherit name src;

  extraInstallCommands =
    ''
      mv $out/bin/${name} $out/bin/${pname}

      install -m 444 -D ${appimageContents}/open-lens.desktop $out/share/applications/${pname}.desktop
      install -m 444 -D ${appimageContents}/usr/share/icons/hicolor/512x512/apps/open-lens.png \
         $out/share/icons/hicolor/512x512/apps/${pname}.png

      substituteInPlace $out/share/applications/${pname}.desktop \
        --replace 'Icon=open-lens' 'Icon=${pname}' \
        --replace 'Exec=AppRun' 'Exec=${pname}'
    '';

  meta = with lib; {
    description = "The Kubernetes IDE";
    homepage = "https://k8slens.dev/";
    license = licenses.mit;
    # maintainers = with maintainers; [ dbirks ];
    platforms = [ "x86_64-linux" ];
  };
}