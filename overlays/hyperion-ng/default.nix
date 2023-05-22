final: prev:
prev.hyperion-ng.overrideAttrs (p: rec {
  version = "2.0.15";
  src = prev.fetchFromGitHub {
    owner = "hyperion-project";
    repo = "hyperion.ng";
    rev = version;
    sha256 = "LbR9BjNQ83QiUj7iKBupfCPPqRGm7ixdDWY4i75GMSI=";
    fetchSubmodules = true;
  };
  buildInputs = p.buildInputs ++ (with prev.pkgs; [
    alsa-lib
  ]);
})
