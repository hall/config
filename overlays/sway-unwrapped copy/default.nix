{ prev, final, ... }:
prev.sway-unwrapped.overrideAttrs (attrs: {
  version = "0-unstable-2024-08-11";
  src = final.fetchFromGitHub {
    owner = "swaywm";
    repo = "sway";
    rev = "b44015578a3d53cdd9436850202d4405696c1f52";
    hash = "sha256-gTsZWtvyEMMgR4vj7Ef+nb+wcXkwGivGfnhnBIfPHOA=";
  };
  buildInputs = attrs.buildInputs ++ [ final.wlroots ];
  mesonFlags =
    let
      inherit (prev.lib.strings) mesonEnable mesonOption;
    in
    [
      (mesonOption "sd-bus-provider" "libsystemd")
      (mesonEnable "tray" attrs.trayEnabled)
    ];
})
