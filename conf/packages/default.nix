{ lib, channels }:
channels.nixpkgs.lib.trivial.pipe (lib.readDirNames ./.) [
  (map (pkg:
    {
      name = pkg;
      value = channels.nixpkgs.callPackage ./${pkg} { };
    }
  ))
  # remove unsupported packages
  (builtins.filter (x: builtins.elem channels.nixpkgs.system x.value.meta.platforms))
  builtins.listToAttrs
]
