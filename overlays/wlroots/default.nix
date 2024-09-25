final: prev:
prev.wlroots.overrideAttrs (_attrs: {
  version = "0-unstable-2024-08-11";
  src = final.fetchFromGitLab {
    domain = "gitlab.freedesktop.org";
    owner = "wlroots";
    repo = "wlroots";
    rev = "6214144735b6b85fa1e191be3afe33d6bea0faee";
    hash = "sha256-nuG2xXLDFsGh23CnhaTtdOshCBN/yILqKCSmqJ53vgI=";
  };
})
