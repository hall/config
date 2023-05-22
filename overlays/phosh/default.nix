final: prev:
prev.phosh.overrideAttrs (p: rec {
  pname = "phosh";
  version = "0.27.0";
  src = prev.fetchFromGitLab {
    domain = "gitlab.gnome.org";
    group = "World";
    owner = "Phosh";
    repo = pname;
    rev = "v${version}";
    fetchSubmodules = true; # including gvc and libcall-ui which are designated as subprojects
    sha256 = "dnSYeXn3aPwvxeIjjk+PsnOVKyuGlxXMXGWDdrRrIM0=";
  };
})
