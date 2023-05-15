{ readDirNames }:
let
  mkHost = { self, path, modules, system }: name:
    let
      inherit (builtins) concatMap elemAt filter map pathExists split;

      platformTuple = split "-" system;
      platform = elemAt platformTuple 2;
      arch = elemAt platformTuple 0;

      fullHostPath = /${path}/${platform}/${arch}/${name};

      usersPath = fullHostPath + /users;
      users = if pathExists usersPath then readDirNames usersPath else [ ];

      paths =
        map (user: ../users/${user}) users ++
        map (user: /${usersPath}/${user}) users ++
        [
          /${path}
          /${path}/${platform}
          /${path}/${platform}/${arch}
          fullHostPath
        ];
    in
    {
      inherit name;
      value = {
        inherit system;
        modules = modules ++ (filter pathExists (map (path: path + /configuration.nix) paths));
        specialArgs = {
          flake = self // {
            packages = self.outputs.packages."${system}";
          };
          hostPath = fullHostPath;
        };
      };
    };

  mkSystem = args@{ path, ... }: system:
    let
      inherit (builtins) split elemAt;
      platformTuple = split "-" system;
      platform = elemAt platformTuple 2;
      arch = elemAt platformTuple 0;
      hosts = readDirNames (path + /${platform}/${arch});
    in
    builtins.map (mkHost (args // { inherit system; })) hosts;
  mkHosts = args@{ self, path, modules }:
    let
      inherit (builtins) concatMap listToAttrs;
      platforms = readDirNames path;
      systems = concatMap
        (platform: map (arch: arch + "-" + platform) (readDirNames /${path}/${platform}))
        platforms;
    in
    listToAttrs (concatMap (mkSystem args) systems);
in
mkHosts
