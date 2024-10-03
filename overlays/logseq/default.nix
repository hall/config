# https://github.com/NixOS/nixpkgs/issues/2648850
final: prev:
prev.logseq.override {
  electron = prev.electron_27;
}
