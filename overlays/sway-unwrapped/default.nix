# https://discourse.nixos.org/t/screen-flickering-and-tearing-with-nixos-sway-nvidia/49469/6
final: prev:
prev.sway-unwrapped.overrideAttrs (attrs: {
  version = "0-unstable-2024-08-11";
  src = final.fetchFromGitHub {
    owner = "swaywm";
    repo = "sway";
    rev = "b44015578a3d53cdd9436850202d4405696c1f52";
    hash = "sha256-gTsZWtvyEMMgR4vj7Ef+nb+wcXkwGivGfnhnBIfPHOA=";
  };
  buildInputs = attrs.buildInputs ++ [ final.wlroots ];
  mesonFlags = with prev.lib.strings;[
    (mesonOption "sd-bus-provider" "libsystemd")
    (mesonEnable "tray" attrs.trayEnabled)
  ];
})
