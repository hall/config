{ lib, config, flake, specialArgs, ... }:
with lib;
let
  name = "home";
  cfg = config.${name};
in
{
  options.${name} = {
    enable = lib.mkEnableOption name;
    packages = lib.mkOption {
      description = "extra configuration options";
      default = [ ];
      # type = lib.types.attrs;
    };
    programs = lib.mkOption {
      description = "extra configuration options";
      default = { };
      type = lib.types.attrs;
    };
    services = lib.mkOption {
      description = "extra configuration options";
      default = { };
      type = lib.types.attrs;
    };
    file = lib.mkOption {
      description = "extra configuration options";
      default = { };
      type = lib.types.attrs;
    };

  };
  config = mkIf cfg.enable {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "backup";
      extraSpecialArgs = specialArgs;
      users.${flake.lib.username} = { pkgs, ... }: {
        programs = lib.mkMerge [ (import ./programs { inherit pkgs flake config; }) cfg.programs ];
        services = cfg.services;
        xsession = {
          enable = true;
          windowManager.command = ''
            ${flake.packages.someblocks}/bin/someblocks -p | ${pkgs.dwl}/bin/dwl &
          '';
        };

        home = {
          username = flake.lib.username;
          homeDirectory = "/home/${flake.lib.username}";
          stateVersion = config.system.stateVersion;
          packages = with pkgs; cfg.packages ++ [
            nixpkgs-fmt
            wl-clipboard
            dnsutils
            inetutils

            pciutils

            gnome-sound-recorder
            ddcutil

            gtop
          ];
          sessionVariables = {
            MOZ_USE_XINPUT2 = "1";
            MOZ_ENABLE_WAYLAND = "1";
          };
          file = cfg.file;
        };
      };

    };
  };
}
