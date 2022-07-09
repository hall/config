{ config, lib, pkgs, flake, hostPath, specialArgs, ... }:

let
  platformTuple = lib.strings.splitString "-" pkgs.stdenv.hostPlatform.system;
  arch = builtins.elemAt platformTuple 0;
  platform = builtins.elemAt platformTuple 1;

  mkUsers = hostPath:
    let

      usersPath = hostPath + /users;
      users = if builtins.pathExists usersPath then flake.lib.readDirNames usersPath else [ ];
    in
    builtins.listToAttrs (builtins.map (mkUser hostPath) users);

  mkUser = hostPath: name:
    let
      srcPaths = [
        ../users/${name}
        (hostPath + /users/${name})
        ./${platform}
        ./${platform}/${arch}
      ];

      homeManagerPaths = builtins.map (path: path + /home-manager) srcPaths;

      dirs = builtins.filter lib.trivial.pathExists homeManagerPaths;
    in
    {
      inherit name;
      value = lib.trivial.pipe dirs [ (builtins.map import) lib.mkMerge ];
    };
in
{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users = mkUsers hostPath;
  home-manager.extraSpecialArgs = specialArgs;
}
