final: prev:
prev.deploy-rs.overrideAttrs (oldAttrs: {
  patches = (oldAttrs.patches or [ ]) ++ [
    ./nix-2.33-compat.patch
  ];
})
