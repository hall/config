let
  mkHost = { self, lib, modules, platform, arch }: name:
    let
      paths = [
        ./.
        ./${platform}
        ./${platform}/${arch}
        ./${platform}/${arch}/${name}
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
          hostPath = ./${platform}/${arch}/${name};
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
