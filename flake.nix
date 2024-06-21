{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home = {
      url = "github:nix-community/home-manager";
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
  };
  outputs = inputs@{ self, systems, ... }:
    let
      eachSystem = f: inputs.nixpkgs.lib.genAttrs (import systems)
        (system: f (import inputs.nixpkgs { inherit system; }));
    in
    rec {

      lib = rec {
        username = "bryton";
        hostname = "${username}.io";
        name = "Bryton Hall";
        email = "email@${hostname}";
      };

      nixosConfigurations = import ./hosts {
        inherit self lib;
        modules = with inputs; (map (i: i.nixosModules.default) [
          agenix
          disko
          home
          musnix
          nixarr
          rekey
        ]) ++ [
          stylix.nixosModules.stylix
          ({ ... }: {
            nixpkgs.overlays = (map (o: o.overlays.default) [
              rekey
              self
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

      packages = with builtins; eachSystem (pkgs:
        (pkgs.lib.trivial.pipe
          # remove accessory files
          (filter (name: !elem name [ "README.md" ])
            (attrNames (readDir ./packages))) [
          (map (name: {
            inherit name;
            value = pkgs.callPackage ./packages/${name} { };
          }))
          # remove unsupported packages
          (filter (x: elem pkgs.system x.value.meta.platforms))
          listToAttrs
        ])
      );

      devShells = eachSystem (pkgs: {
        default = with pkgs; mkShell {
          buildInputs = [
            deploy-rs
            inputs.rekey.packages.${system}.default
            nixos-anywhere
            nvd
          ];
        };
      });

      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) inputs.deploy.lib;

      deploy.nodes = builtins.mapAttrs
        (hostname: config: {
          inherit hostname;
          profiles.system = {
            user = "root";
            path = inputs.deploy.lib.${config.pkgs.system}.activate.nixos config;
          };
        })
        self.nixosConfigurations;

      agenix-rekey = inputs.rekey.configure {
        userFlake = self;
        nodes = self.nixosConfigurations;
      };

    };
}
