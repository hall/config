{
  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/nixos-22.05;
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    hardware.url = github:NixOS/nixos-hardware/master;
    nur.url = github:nix-community/nur;
    home-manager = {
      url = github:nix-community/home-manager;
      inputs.nixpkgs.follows = "nixpkgs";
    };
    musnix.url = github:musnix/musnix;
    mach.url = github:davhau/mach-nix;
    utils.url = github:gytis-ivaskevicius/flake-utils-plus/v1.3.1;
    mobile = {
      # url = github:nixos/mobile-nixos/master;
      url = github:samueldr-wip/mobile-nixos-wip/wip/pinephone-pro;
      flake = false;
    };
  };
  outputs = inputs@{ self, home-manager, ... }:
    let
      inherit (inputs.nixpkgs.lib) recursiveUpdate;

      lib = import ./lib;
    in
    inputs.utils.lib.mkFlake rec {
      inherit self inputs lib;

      username = "bryton";
      hostname = "${username}.io";

      name = "Bryton Hall";
      email = "email@${hostname}";

      channelsConfig = {
        # allowBroken = true;
        allowUnfreePredicate = pkg: builtins.elem (inputs.nixpkgs.lib.getName pkg) [
          "vscode-extension-ms-toolsai-jupyter"
          "slack"
        ];
      };

      hostDefaults = {
        modules = [
          ./hosts/configuration.nix
          inputs.musnix.nixosModules.musnix
        ] ++ (import ./modules);
      };

      hosts = lib.mkHosts {
        inherit self;
        hostsPath = ./hosts;
      };

      sharedOverlays = [
        inputs.nur.overlay
      ];

      outputsBuilder = channels: {
        packages =
          let
            inherit (channels.nixpkgs.stdenv.hostPlatform) system;
          in
          (import ./packages) { inherit lib channels; } // { };
      };
    };
}
