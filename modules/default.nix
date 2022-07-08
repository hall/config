with builtins;
map (x: ./${x})
  (attrNames
    (removeAttrs
      (readDir ./.)
      [ "default.nix" ]
    )
  )
