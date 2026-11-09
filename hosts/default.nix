let
  # create list of directories at path
  readDirNames =
    with builtins;
    path:
    let
      files = readDir path;
      isDirectory = name: (files."${name}" == "directory") && (substring 0 1 name != ".");
    in
    filter isDirectory (attrNames files);

  mkHost =
    {
      self,
      modules,
      platform,
      arch,
    }:
    name:
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
        modules =
          modules
          ++ [
            # networking.hostName defaults to `nixos`
            (_: { config.networking.hostName = name; })
          ]
          ++ (with builtins; filter pathExists (map (path: path + /configuration.nix) paths));
        specialArgs = {
          flake = self // {
            packages = self.outputs.packages."${arch}-${platform}";
          };
        };
      };
    };
in

args:
with builtins;
listToAttrs (
  concatMap (
    platform:
    concatMap (
      arch: map (mkHost (args // { inherit platform arch; })) (readDirNames ./${platform}/${arch})
    ) (readDirNames ./${platform})
    # openwrt devices are built by dewclaw, not nixosSystem
  ) (filter (platform: platform != "openwrt") (readDirNames ./.))
)
