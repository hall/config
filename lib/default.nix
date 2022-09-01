{ ... }: rec {
  mkHosts = import ./mkHosts.nix { inherit readDirNames; };

  readDirNames = path:
    let
      files = builtins.readDir path;
      isDirectory = name: files."${name}" == "directory";
    in
    builtins.filter isDirectory (builtins.attrNames files);
}
