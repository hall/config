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
    musnix.url = github:musnix/musnix;
    mach.url = github:davhau/mach-nix;
    utils.url = github:gytis-ivaskevicius/flake-utils-plus/v1.3.1;
    mobile = {
      # url = github:nixos/mobile-nixos/master;
      # https://github.com/NixOS/mobile-nixos/pull/445
      url = github:samueldr-wip/mobile-nixos-wip/wip/pinephone-pro;
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

      channelsConfig = {
        # allowBroken = true;
        allowUnfreePredicate = pkg: builtins.elem (inputs.nixpkgs.lib.getName pkg) [
          "vscode-extension-ms-toolsai-jupyter"
          "vscode-extension-ms-vscode-cpptools"
          "slack"
        ];
      };

      hostDefaults = {
        modules = [
          ./hosts/configuration.nix
          inputs.agenix.nixosModule
          inputs.musnix.nixosModules.musnix
        ] ++ (import ./modules);
      };

      hosts = lib.mkHosts {
        inherit self;
        hostsPath = ./hosts;
      };

      images = builtins.mapAttrs
        (_: host:
          let
            keys = {
              "aarch64-linux" = "sdImage";
              "x86_64-linux" = "isoImage";
            };
          in
          if builtins.elem "mobile" (builtins.attrNames host)
          then host.config.mobile.outputs.u-boot.disk-image
          else host.config.system.build.${keys.${host.pkgs.system}}
        )
        self.outputs.nixosConfigurations;

      sharedOverlays = [
        inputs.nur.overlay
        (import ./overlays { inherit lib; })
      ];

      outputsBuilder = channels: {
        packages = (import ./packages) {
          inherit lib channels;
        };
      };

    };
}
