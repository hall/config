let
  mkHost = { self, lib, modules, platform, arch }: name:
    let
      hostPath = ./${platform}/${arch}/${name};
      usersPath = hostPath + /users;
      users = if builtins.pathExists usersPath then lib.readDirNames usersPath else [ ];

      paths =
        map (user: ../users/${user}) users ++
        map (user: /${usersPath}/${user}) users ++
        [
          ./.
          ./${platform}
          ./${platform}/${arch}
          hostPath
        ];
    in
    {
      inherit name;
      value = self.inputs.nixpkgs.lib.nixosSystem {
        system = "${arch}-${platform}";
        modules = modules ++ [
          # TODO: not sure why the hostname gets set to `nixos`
          ({ ... }: { config.networking.hostName = name; })
        ] ++ (with builtins; filter pathExists (map (path: path + /configuration.nix) paths));
        specialArgs = {
          inherit hostPath;
          flake = self // {
            packages = self.outputs.packages."${arch}-${platform}";
          };
        };
      };
    };
in

args@{ self, lib, modules }: with builtins;
listToAttrs (concatMap
  (platform: concatMap
    (arch: map
      (mkHost (args // { inherit platform arch; }))
      (lib.readDirNames ./${platform}/${arch})
    )
    (lib.readDirNames ./${platform})
  )
  (lib.readDirNames ./.)
)
