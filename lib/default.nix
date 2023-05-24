{ flake, ... }: rec {
  # create list of directories at path
  readDirNames = with builtins; path:
    let
      files = readDir path;
      isDirectory = name: (files."${name}" == "directory") && (name != "home");
    in
    filter isDirectory (attrNames files);

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

  # get list of systems present
  supported = builtins.concatMap
    (platform: map (arch: arch + "-" + platform) (readDirNames ../hosts/${platform}))
    (readDirNames ../hosts);

  # create an attrset of supported systems to their corresponding nixpkgs
  systems = function: flake.inputs.nixpkgs.lib.genAttrs supported
    (system: function flake.inputs.nixpkgs.legacyPackages.${system});
}
