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
          inputs.agenix.nixosModule
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
          default = kube;
          kube = channels.nixpkgs.mkShell {
          buildInputs = with channels.nixpkgs.pkgs; [
            kubernetes-helm
          ];
          };
          cad = with channels.nixpkgs; pkgs.mkShell {
            # can't use mach due to https://github.com/DavHau/mach-nix/issues/199
            # buildInputs = with pkgs; [ conda ];
            shellHook = ''
              conda-shell -c '
                conda install -y -c conda-forge -c cadquery python=3.10 cadquery=master vtk=9.2.2;
                pip install \
                    autopep8 \
                    jupyter-cadquery==3.5.2 \
                    cadquery-massembly==1.0.0 \
                    cqkit \
                    ipyplot \
                    matplotlib
                '
              export PYTHONPATH=$PYTHONPATH:$(pwd)
              lab() { conda-shell -c 'jupyter lab --no-browser --ServerApp.token=849d61a414abafab97bc4aab1f3547755ddc232c2b8cb7fe'; };
              export -f lab
            '';
          };
        };
        apps.keyboard = inputs.utils.lib.mkApp {
          drv = channels.nixpkgs.writeShellScriptBin "kbd" (with channels.nixpkgs; ''
            ${gnumake}/bin/make QMK=${qmk}/bin/qmk -C keyboard
          '');
        };
      };

    };
}
