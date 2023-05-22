{
  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/nixos-unstable;
    hardware.url = github:nixos/nixos-hardware/master;
    nur.url = github:nix-community/nur;
    home = {
      url = github:nix-community/home-manager;
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix.url = "github:ryantm/agenix";
    deploy.url = "github:serokell/deploy-rs";
    musnix.url = github:musnix/musnix;
    mach.url = github:davhau/mach-nix/3.5.0;
    kubenix.url = "github:hall/kubenix";
    generators.url = github:nix-community/nixos-generators;
    mobile = {
      # https://github.com/NixOS/mobile-nixos/pull/445
      # url = github:nixos/mobile-nixos/pull/535/head;
      url = "/home/bryton/src/github.com/nixos/mobile-nixos";
      flake = false;
    };
  };
  outputs = inputs@{ self, ... }: rec {

    lib = import ./lib { flake = self; } // rec {
      username = "bryton";
      hostname = "${username}.io";
      name = "Bryton Hall";
      email = "email@${hostname}";
    };

    nixosConfigurations = lib.mkHosts {
      inherit self;
      path = ./hosts;
      modules = [
        inputs.home.nixosModules.home-manager
        inputs.agenix.nixosModules.default
        inputs.musnix.nixosModules.musnix
        ({ ... }: {
          nixpkgs.overlays = [
            inputs.nur.overlay
            self.overlays.default
          ];
        })
      ] ++ (with builtins;
        map (x: ./modules/${x}) (attrNames (readDir ./modules)));
    };

    overlays.default = final: prev: with builtins; listToAttrs (map
      (name: {
        inherit name;
        value = import ./overlays/${name} final prev;
        # value = ./overlays/${name};
      })
      (attrNames (readDir ./overlays))
    );

    packages = lib.systems (pkgs:
      pkgs.lib.trivial.pipe (lib.readDirNames ./packages) [
        (map (name: {
          inherit name;
          value = pkgs.callPackage ./packages/${name} { };
        }))
        # remove unsupported packages
        (builtins.filter (x: builtins.elem pkgs.system x.value.meta.platforms))
        builtins.listToAttrs
      ]
    );

    devShells = lib.systems (pkgs: {
      default = with pkgs; mkShell {
        buildInputs = [
          kubectl
          kubie
          kubernetes-helm
        ];
        KUBECONFIG = "/run/secrets/kubeconfig";
      };
    });

    checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) inputs.deploy.lib;

    deploy.nodes = builtins.mapAttrs
      (name: config: {
        hostname = name;
        profiles.system = {
          user = "root";
          path = inputs.deploy.lib.${config.pkgs.system}.activate.nixos config;
        };
      })
      self.nixosConfigurations;


    kubenix = lib.systems (pkgs: import ./cluster {
      inherit (pkgs) lib;
      flake = self;
      evalModules = inputs.kubenix.evalModules.${pkgs.system};
    });

  };
}
