{
  description = "config";
  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/nixos-unstable;
    unstable.url = github:nixos/nixpkgs/nixos-unstable;
    nur.url = github:nix-community/nur;
    hm.url = github:nix-community/home-manager; #/release-21.11;
    musnix.url = github:musnix/musnix;
    mach.url = github:davhau/mach-nix/3.3.0;
  };
  outputs = inputs@{ self, ... }: {
    nixosConfigurations.rigetti = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules =
        let
          overlay-unstable = final: prev: {
            unstable = inputs.unstable.legacyPackages.x86_64-linux;
          };
          pkgs = (import inputs.nixpkgs { system = "x86_64-linux"; }).pkgs;
          mach = import inputs.mach {
            inherit pkgs;
            python = "python3";
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
          (import ./configuration.nix { mach-nix = mach; pkgs = pkgs; })
          inputs.musnix.nixosModules.musnix
          inputs.hm.nixosModules.home-manager
          {
            nixpkgs.config = {
              # allowBroken = true; # syncthing
              # allowUnfree = true;
              allowUnfreePredicate = pkg: builtins.elem (inputs.nixpkgs.lib.getName pkg) [
                "vscode-extension-ms-toolsai-jupyter"
                "onepassword-password-manager"
                # "zoom"
                "slack"
                "discord"
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
