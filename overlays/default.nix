{ lib }:

final: prev:

builtins.listToAttrs
  (map
    (overlay: {
      name = overlay;
      value = import ./${ overlay} final prev;
    })
    (lib.readDirNames ./.))
