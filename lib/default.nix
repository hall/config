{ flake, ... }: rec {
  mkHosts = import ./mkHosts.nix { inherit readDirNames; };

  readDirNames = path:
    let
      files = builtins.readDir path;
      isDirectory = name: files."${name}" == "directory";
    in
    builtins.filter isDirectory (builtins.attrNames files);

  # merge a list of sets https://stackoverflow.com/a/54505212
  recursiveMerge = with builtins; attrList:
    let f = attrPath:
      zipAttrsWith (n: values:
        if tail values == [ ]
        then head values
        else if all isList values
        then unique (concatLists values)
        else if all isAttrs values
        then f (attrPath ++ [ n ]) values
        else lib.lists.last values
      );
    in f [ ] attrList;

  # create an attrset of supported systems to their corresponding nixpkgs
  systems = function: flake.inputs.nixpkgs.lib.genAttrs [
    "x86_64-linux"
    "aarch64-linux"
  ]
    (system: function flake.inputs.nixpkgs.legacyPackages.${system});
}
