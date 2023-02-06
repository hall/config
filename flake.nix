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
    # removes evalModules deprecation warning which is not yet included in any release
    utils.url = github:gytis-ivaskevicius/flake-utils-plus/be1be083af014720c14f3b574f57b6173b4915d0;
    mobile = {
      # https://github.com/NixOS/mobile-nixos/pull/445
      url = github:nixos/mobile-nixos/pull/445/head;
      # url = github:wentam/mobile-nixos-wip/wip/pinephone-pro;
      flake = false;
    };
  };
  outputs = inputs@{ self, ... }:
    inputs.utils.lib.mkFlake rec {
      inherit self inputs;
      lib = import ./lib { flake = self; };

      username = "bryton";
      hostname = "${username}.io";

      name = "Bryton Hall";
      email = "email@${hostname}";

      hostDefaults = {
        modules = [
          inputs.agenix.nixosModules.default
          inputs.musnix.nixosModules.musnix
        ] ++ (import ./modules);
      };

      hosts = lib.mkHosts {
        inherit self;
        hostsPath = ./hosts;
      };

      deploy.nodes = builtins.mapAttrs
        (name: config: {
          hostname = name;
          profiles.system = {
            user = "root";
            path = inputs.deploy.lib.${config.pkgs.system}.activate.nixos config;
          };
        })
        self.nixosConfigurations
      ;

      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) inputs.deploy.lib;

      sharedOverlays = [
        inputs.nur.overlay
        (import ./overlays { inherit lib; })
      ];

      outputsBuilder = channels: {
        packages = ((import ./packages) { inherit lib channels; });
        kubenix = import ./cluster {
          flake = self;
          evalModules = inputs.kubenix.evalModules.${channels.nixpkgs.system};
          inherit (channels.nixpkgs.pkgs) lib;
        };

        devShells = rec {
          default = cad;
          kube = channels.nixpkgs.mkShell {
          buildInputs = with channels.nixpkgs.pkgs; [
            kubernetes-helm
            ];
          };
          cad = channels.nixpkgs.pkgs.callPackage ./cad { };
        };
      };

    };
}
