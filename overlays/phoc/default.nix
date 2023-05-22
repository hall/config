final: prev:
prev.phoc.overrideAttrs (p: rec {
  pname = "phoc";
  version = "0.27.0";
  src = prev.fetchFromGitLab {
    domain = "gitlab.gnome.org";
    group = "World";
    owner = "Phosh";
    repo = pname;
    rev = "v${version}";
    fetchSubmodules = true; # including gvc and libcall-ui which are designated as subprojects
    sha256 = "4/Fxo72KXLy3gxXMS+PrTUbZl0EFt2GPMXg8+/fE7MY=";
  };
})
