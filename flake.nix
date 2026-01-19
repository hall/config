{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    stable.url = "github:nixos/nixpkgs/nixos-24.11";
    home = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hardware.url = "github:nixos/nixos-hardware";
    impermanence.url = "github:nix-community/impermanence";
    nur = {
      url = "github:nix-community/nur";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rekey = {
      url = "github:oddlama/agenix-rekey";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    deploy = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    musnix = {
      url = "github:musnix/musnix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mobile = {
      url = "github:nixos/mobile-nixos";
      flake = false;
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vscode = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vpn.url = "github:Maroka-chan/VPN-Confinement";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs@{ self, systems, ... }:
    let
      eachSystem = f: inputs.nixpkgs.lib.genAttrs (import systems)
        (system: f (import inputs.nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [ self.overlays.default ];
        }));
    in
    rec {

      lib = rec {
        username = "bryton";
        hostname = "${username}.io";
        name = "Bryton Hall";
        email = "email@${hostname}";

        # https://discourse.nixos.org/t/nix-function-to-merge-attributes-records-recursively-and-concatenate-arrays/2030
        recursiveMergeAttrs = with inputs.nixpkgs.lib; fold (attrset: acc: recursiveUpdate attrset acc) { };
      };

      nixosConfigurations = import ./hosts {
        inherit self lib;
        modules = with inputs; (map (i: i.nixosModules.default) [
          agenix
          disko
          home
          # musnix
          rekey
          vpn
        ]) ++ [
          impermanence.nixosModules.impermanence
          stylix.nixosModules.stylix
          nur.modules.nixos.default
          ({ ... }: {
            nixpkgs.overlays = (map (o: o.overlays.default) [
              rekey
              self
              vscode
            ] ++ [
              (final: _: {
                stable = import inputs.stable {
                  inherit (final.stdenv.hostPlatform) system;
                  inherit (final) config;
                };
              })
            ]);
          })
        ] ++ (with builtins; map (x: ./modules/${x}) (attrNames (readDir ./modules)));
      };

      overlays.default = final: prev: with builtins; listToAttrs (map
        (name: {
          inherit name;
          value = import ./overlays/${name} final prev;
        })
        (attrNames (readDir ./overlays))
      );

      images = builtins.mapAttrs
        (name: config:
          let
            arch = builtins.head (builtins.split "-" config.pkgs.stdenv.hostPlatform.system);
            imageType = {
              "aarch64" = { module = inputs.nixos-generators.nixosModules.sd-aarch64; output = "sdImage"; };
              "x86_64" = { module = inputs.nixos-generators.nixosModules.iso; output = "isoImage"; };
            }.${arch};
          in
          (config.extendModules { modules = [ imageType.module ]; }).config.system.build.${imageType.output}
        )
        nixosConfigurations;

      packages = with builtins; eachSystem (pkgs:
        (pkgs.lib.trivial.pipe
          # remove "disabled" packages
          (filter (name: !pkgs.lib.hasPrefix "." name)
            (attrNames (readDir ./packages))) [
          (map (name: {
            inherit name;
            value = pkgs.callPackage ./packages/${name} { };
          }))
          # remove unsupported packages
          (filter (x: elem pkgs.stdenv.hostPlatform.system x.value.meta.platforms))
          listToAttrs
        ])
      );

      devShells = eachSystem (pkgs: {
        default = with pkgs; mkShell {
          buildInputs = [
            nixos-anywhere
            # nixos-rebuild build --flake "$@" && nvd diff /run/current-system result
            nvd
            claude-code
            gemini-cli
            deploy-rs
          ] ++ (map (i: i.packages.${stdenv.hostPlatform.system}.default) [
            inputs.rekey
          ]);
        };
      });

      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) inputs.deploy.lib;

      deploy.nodes = builtins.mapAttrs
        (hostname: config: {
          inherit hostname;
          profiles.system = {
            user = "root";
            path = inputs.deploy.lib.${config.pkgs.stdenv.hostPlatform.system}.activate.nixos config;
          };
        })
        self.nixosConfigurations;

      agenix-rekey = inputs.rekey.configure {
        inherit (self) nixosConfigurations;
        userFlake = self;
      };

      apps = eachSystem (pkgs: {
        flash = {
          type = "app";
          program = toString (pkgs.writeShellScript "flash" ''
            set -euo pipefail

            echo "Select a host:"
            host=$(echo "${builtins.concatStringsSep "\n" (builtins.attrNames nixosConfigurations)}" | ${pkgs.gum}/bin/gum choose)
            if [ -z "$host" ]; then
              echo "No host selected"
              exit 1
            fi

            echo "Select a device:"
            device=$(${pkgs.util-linux}/bin/lsblk -d -n -p -o NAME | ${pkgs.gum}/bin/gum choose)
            if [ -z "$device" ]; then
              echo "No device selected"
              exit 1
            fi

            size=$(${pkgs.util-linux}/bin/lsblk -d -n -o SIZE "$device")
            model=$(${pkgs.util-linux}/bin/lsblk -d -n -o MODEL "$device")
            ${pkgs.gum}/bin/gum confirm "Flash $host to $device ($size $model)?" || exit 1

            echo "Building image for $host..."
            imagePath=$(${pkgs.nix}/bin/nix build ".#images.$host" --no-link --print-out-paths)
            imageFile=$(find "$imagePath" -name '*.img.zst' -o -name '*.img' -o -name '*.iso' 2>/dev/null | head -n1)

            echo "Flashing $imageFile to $device..."
            if [[ "$imageFile" == *.zst ]]; then
              ${pkgs.zstd}/bin/zstdcat "$imageFile" | sudo ${pkgs.coreutils}/bin/dd of="$device" bs=4M status=progress conv=fsync
            else
              sudo ${pkgs.coreutils}/bin/dd if="$imageFile" of="$device" bs=4M status=progress conv=fsync
            fi
            sudo ${pkgs.coreutils}/bin/sync
            echo "Done!"
          '');
        };
      });

    };
}
