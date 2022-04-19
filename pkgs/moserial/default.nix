{ lib
, stdenv
, fetchFromGitLab
, autoreconfHook
, intltool
, itstool
, pkg-config
, vala
, glib
, graphviz
, yelp-tools
, gtk3
, lrzsz
}:

stdenv.mkDerivation rec {
  pname = "moserial";
  version = "3.0.21";

  src = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "GNOME";
    repo = pname;
    rev = "moserial_${builtins.replaceStrings [ "." ] [ "_" ] version}";
    sha256 = "sha256-wfdI51ECqVNcUrIVjYBijf/yqpiwSQeMiKaVJSSma3k=";
  };

  buildInputs = [
    glib
    graphviz
    yelp-tools
    gtk3
  ];

  nativeBuildInputs = [
    autoreconfHook
    intltool
    itstool
    pkg-config
    vala
  ];

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix PATH : ${lib.makeBinPath [ lrzsz ]}
    )
  '';

  meta = with lib; {
    description = "clean, friendly gtk-based serial terminal for the gnome desktop";
    homepage = "https://wiki.gnome.org/moserial";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ linsui ];
    platforms = platforms.linux;
    mainProgram = "moserial";
  };
}
