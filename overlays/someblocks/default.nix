# TODO: doesn't work since this package is defined locally
final: prev:
prev.someblocks.override {
  conf = ./config.h;
}
