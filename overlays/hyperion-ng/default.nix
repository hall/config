self: super:
super.hyperion-ng.overrideAttrs
  (prev: rec {
    version = "2.0.15";
    src = super.fetchFromGitHub {
      owner = "hyperion-project";
      repo = "hyperion.ng";
      rev = version;
      sha256 = "LbR9BjNQ83QiUj7iKBupfCPPqRGm7ixdDWY4i75GMSI=";
      fetchSubmodules = true;
    };
    buildInputs = prev.buildInputs ++ (with super.pkgs; [
      alsa-lib
    ]);
  })
