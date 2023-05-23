final: prev:
prev.feedbackd.overrideAttrs (p: rec {
  pname = "feedbackd";
  version = "0.2.0";
  src = prev.fetchFromGitLab {
    domain = "source.puri.sm";
    owner = "Librem5";
    repo = "feedbackd";
    rev = "v${version}";
    sha256 = "l5rfMx3ElW25A5WVqzfKBp57ebaNC9msqV7mvnwv10s=";
    fetchSubmodules = true;
  };
  patches = [ ];
})
