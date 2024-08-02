final: prev:
prev.keyd.overrideAttrs (old: {
  patches = (old.patches or [ ]) ++ [
    ./gamepad.patch
  ];
})
