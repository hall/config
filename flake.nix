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
          default = cad;
          kube = channels.nixpkgs.mkShell {
          buildInputs = with channels.nixpkgs.pkgs; [
            kubernetes-helm
          ];
          };
          cad = with channels.nixpkgs; let
            libs = [
              stdenv.cc.cc
              gfortran.cc.lib
              xorg.libX11
              libGL
              expat
              zlib
            ];
          in
          mkShell {
            buildInputs = [
              (python3.withPackages (p: with p; [
                autopep8
              ]))
              python3Packages.pip
            ];
            shellHook = ''
              # Tells pip to put packages into $PIP_PREFIX instead of the usual locations.
              # See https://pip.pypa.io/en/stable/user_guide/#environment-variables.
              export PIP_PREFIX=$(pwd)/_build/pip_packages
              export PYTHONPATH="$PIP_PREFIX/${pkgs.python3.sitePackages}:$PYTHONPATH"
              export PATH="$PIP_PREFIX/bin:$PATH"
              unset SOURCE_DATE_EPOCH

              export LD_LIBRARY_PATH=${channels.nixpkgs.lib.makeLibraryPath libs}
                
                pip install \
                  cadquery-server \
                  cadquery==2.2.0b2 # cq-vscode \
                  https://github.com/bernhard-42/vscode-cadquery-viewer/releases/download/v0.13.0/cq_vscode-0.13.0-py3-none-any.whl
              
              # cq-server run --ui-theme dark ./cad
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
