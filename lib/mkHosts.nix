let
  inherit (import ./.) readDirNames;

  mkHost = { self, hostsPath, system }: name:
    let
      inherit (builtins) concatMap elemAt filter map pathExists split;

      platformTuple = split "-" system;
      platform = elemAt platformTuple 2;
      arch = elemAt platformTuple 0;

      fullHostPath = /${hostsPath}/${platform}/${arch}/${name};

      usersPath = fullHostPath + /users;
      users = if pathExists usersPath then readDirNames usersPath else [ ];

      paths =
        map (user: ../users/${user}) users ++
        map (user: usersPath + /${user}) users ++
        [
          ../hosts/${platform}
          ../hosts/${platform}/${arch}
          fullHostPath
        ];

      configs = filter pathExists
        (map (path: path + /configuration.nix) paths);

      modulesConfigs = concatMap
        (src: import src self)
        (filter pathExists
          (map (path: path + /modules.nix) paths));
    in
    {
      inherit name;
      value = {
        inherit system;
        modules = configs ++ modulesConfigs;
        specialArgs = {
          flake = self // {
            packages = self.outputs.packages."${system}";
            unstable = self.outputs.pkgs."${system}".unstable;
          };
          hostPath = fullHostPath;
        };
      };
    };

  mkSystem = args@{ hostsPath, ... }: system:
    let
      inherit (builtins) split elemAt;
      platformTuple = split "-" system;
      platform = elemAt platformTuple 2;
      arch = elemAt platformTuple 0;
      hosts = readDirNames (hostsPath + /${platform}/${ arch});
    in
    builtins.map (mkHost (args // { inherit system; })) hosts;
  mkHosts = args@{ self, hostsPath }:
    let
      inherit (builtins) concatMap listToAttrs;
      platforms = readDirNames hostsPath;
      systems = concatMap
        (platform: map (arch: arch + "-" + platform) (readDirNames /${ hostsPath}/${ platform})) platforms;
    in
    listToAttrs (concatMap (mkSystem args) systems);
in
mkHosts
