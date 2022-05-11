{
  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/nixos-unstable;
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    stable.url = github:nixos/nixpkgs/nixos-21.11;
    nur.url = github:nix-community/nur;
    home-manager.url = github:nix-community/home-manager; #/release-21.11;
    musnix.url = github:musnix/musnix;
    mach.url = github:davhau/mach-nix;
    utils.url = github:gytis-ivaskevicius/flake-utils-plus/v1.3.1;
    # mobile.url = github:nixos/mobile-nixos/master;
  };
  outputs = inputs@{ self, home-manager, ... }:
    let
      inherit (inputs.nixpkgs.lib) recursiveUpdate;

      lib = import ./lib;
      overlays = import ./overlays { inherit lib; };
      packages = import ./pkgs;
    in
    inputs.utils.lib.mkFlake rec {
      inherit self inputs lib;
      channelsConfig = {
        # allowBroken = true;
        allowUnfreePredicate = pkg: builtins.elem (inputs.nixpkgs.lib.getName pkg) [
          "vscode-extension-ms-toolsai-jupyter"
          "slack"
        ];
      };

      hostDefaults.modules = [
        ./common/configuration.nix
      ];

      hosts = lib.mkHosts {
        inherit self;
        hostsPath = ./hosts;
      };

      sharedOverlays = [
        overlays
        inputs.nur.overlay
      ];

      outputsBuilder = channels: {
        packages =
          let
            inherit (channels.nixpkgs.stdenv.hostPlatform) system;
          in
          packages { inherit lib channels; } // { };
      };
    };
}
