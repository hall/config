{ lib, channels }:
channels.nixpkgs.lib.trivial.pipe (lib.readDirNames ./.) [
  (map (pkg:
    {
      name = pkg;
      value = channels.nixpkgs.callPackage ./${pkg} {};
    }
  ))
  builtins.listToAttrs
]
