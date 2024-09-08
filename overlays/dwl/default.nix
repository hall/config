final: prev:
(prev.dwl.overrideAttrs (old: {
  # src = prev.fetchFromGitea {
  #   domain = "codeberg.org";
  #   owner = "dwl";
  #   repo = "dwl";
  #   rev = old.version;
  #   hash = "sha256-eh5dJ6rnwjqiUXzffhAN5pQ8JUxZEJuJS4G2Dod+wgk=";
  # };

  buildInputs = with prev; old.buildInputs ++ [
    fcft
    libdrm
  ];

  patches =
    let
      dwl-patches = (prev.fetchFromGitea {
        domain = "codeberg.org";
        owner = "dwl";
        repo = "dwl-patches";
        rev = "main";
        hash = "sha256-Yh1gyU7/L5+4DEuf5MMl57McedK/s1JPCZrBF64e40I=";
      }) + "/patches";
    in
    (old.patches or [ ]) ++ [
      "${dwl-patches}/bar/bar-0.7.patch"
      # TODO: broken
      #"${dwl-patches}/less-simple-touch-input/less-simple-touch-input.patch"
      ./touch.patch
    ];
})).override {
  configH = ./config.h;
  enableXWayland = false;
}
