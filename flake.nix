{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    hardware.url = "github:nixos/nixos-hardware/master";
    nur.url = "github:nix-community/nur";
    home.url = "github:nix-community/home-manager";
    agenix.url = "github:ryantm/agenix";
    deploy.url = "github:serokell/deploy-rs";
    musnix.url = "github:musnix/musnix";
    mach.url = "github:davhau/mach-nix/3.5.0";
    kubenix.url = "github:hall/kubenix/helmless-cli";
    mobile = {
      # https://github.com/NixOS/mobile-nixos/pull/445
      # url = github:nixos/mobile-nixos/pull/535/head;
      url = "/home/bryton/src/github.com/nixos/mobile-nixos";
      flake = false;
    };
  };
  outputs = inputs@{ self, ... }: rec {

    lib = rec {
      username = "bryton";
      hostname = "${username}.io";
      name = "Bryton Hall";
      email = "email@${hostname}";
      # create an attrset of supported systems to their corresponding nixpkgs
      systems = function: inputs.nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ]
        (system: function inputs.nixpkgs.legacyPackages.${system});
    };

    nixosConfigurations = import ./hosts {
      inherit self lib;
      modules = with inputs; [
        home.nixosModules.home-manager
        agenix.nixosModules.default
        musnix.nixosModules.musnix
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
      })
      (attrNames (readDir ./overlays))
    );

    packages = with builtins; lib.systems (pkgs:
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
      ]) // {
        kubenix = inputs.kubenix.packages.${pkgs.system}.default.override {
          module = import ./cluster;
          specialArgs = { flake = self; };
        };
      }
    );

    devShells = lib.systems (pkgs: {
      default = with pkgs; mkShell {
        buildInputs = [ kubectl ];
        KUBECONFIG = "/run/secrets/kubeconfig";
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

  };
}
