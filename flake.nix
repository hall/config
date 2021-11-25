{
  description = "config";
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/21.11-pre;
    unstable.url = github:NixOS/nixpkgs/nixos-unstable;
    nur.url = github:nix-community/NUR;
    hm.url = github:nix-community/home-manager/release-21.11;
    musnix.url = github:musnix/musnix;
    fup.url = "github:gytis-ivaskevicius/flake-utils-plus";
  };
  outputs = inputs@{ self, ... }: {
    nixosConfigurations.rigetti = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules =
        let
          overlay-unstable = final: prev: {
            unstable = inputs.unstable.legacyPackages.x86_64-linux;
          };
        in
        [
          {
            nixpkgs.overlays = [
              inputs.nur.overlay
              overlay-unstable
            ];
          }
          ./hardware.nix
          ./configuration.nix
          inputs.musnix.nixosModules.musnix
          inputs.hm.nixosModules.home-manager
          {
            nixpkgs.config = {
              allowBroken = true; # syncthing
              allowUnfreePredicate = pkg: builtins.elem (inputs.nixpkgs.lib.getName pkg) [
                "vscode-extension-ms-toolsai-jupyter"
                # "zoom"
                # "slack"
                # "discord"
              ];
            };
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.bryton = import ./home;
          }
        ];
    };
  };
}
