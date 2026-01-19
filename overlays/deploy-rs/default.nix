final: prev:
prev.deploy-rs.overrideAttrs (oldAttrs: {
  patches = (oldAttrs.patches or [ ]) ++ [
    # https://github.com/serokell/deploy-rs/issues/355#issuecomment-3685955253
    ./nix-2.33-compat.patch
  ];
})
