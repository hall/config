let
  inherit (import ./.) readDirNames;

  mkHost = { self, hostsPath, system }: name:
    let
      inherit (builtins) concatMap elemAt filter map mapAttrs pathExists split;
      inherit (self.inputs) home-manager;

      # Define `optionalAttrs` and `id` manually because trying to access
      # `self.input.nixpkgs` causes an infinite recursion.
      optionalAttrs = pred: attrs: if pred then attrs else { };

      platformTuple = split "-" system;
      platform = elemAt platformTuple 2;
      arch = elemAt platformTuple 0;

      fullHostPath = ../hosts/${platform}/${arch}/${name};
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

      configPaths = map (path: path + /configuration.nix) paths;
      configs = filter pathExists configPaths;

      modulesPaths = map (path: path + /modules.nix) paths;
      modulesConfigs = concatMap (src: import src self) (filter pathExists modulesPaths);
    in
    {
      inherit name;
      value = {
        inherit system;
        modules = configs ++ modulesConfigs;
        specialArgs = {
          flake = self;
          hostPath = fullHostPath;
          flakePkgs = self.outputs.flakePkgs."${system}";
          unstablePkgs = self.outputs.pkgs."${system}".nixpkgs-unstable;
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
      os = readDirNames hostsPath;
      systems = builtins.concatMap (x: map (y: y + "-" + x) (readDirNames /${ hostsPath}/${ x})) os;
    in
    listToAttrs (concatMap (mkSystem args) systems);
in
mkHosts
