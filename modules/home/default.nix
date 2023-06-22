{ lib, config, pkgs, flake, specialArgs, ... }:
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

  };
  config = mkIf cfg.enable {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      users.${flake.lib.username} = { pkgs, ... }: #lib.mkMerge [
        # cfg.home
        {
          accounts = import ./accounts.nix { inherit flake; };
          dconf = import ./dconf.nix;
          gtk = import ./gtk.nix pkgs;
          programs = lib.mkMerge [ (import ./programs { inherit pkgs flake; }) cfg.programs ];
          services = lib.mkMerge [ (import ./services.nix) cfg.services ];
          systemd = import ./systemd.nix pkgs;
          xdg = import ./xdg.nix pkgs;

          home = {
            username = flake.lib.username;
            homeDirectory = "/home/${flake.lib.username}";
            # https://nix-community.github.io/home-manager/release-notes.html
            stateVersion = "22.11";
            packages = (import ./packages.nix { inherit config pkgs flake lib; }) ++ cfg.packages;
            sessionVariables = {
              CALIBRE_USE_DARK_PALETTE = "1";
            };
            file = let path = ./stage; in
              builtins.listToAttrs
                (map
                  (file:
                    let
                      # get relative filename
                      filename = lib.strings.removePrefix "${(builtins.toString path)}/" (builtins.toString file);
                    in
                    {
                      name = filename;
                      value = {
                        source = path + "/${filename}";
                        target = filename;
                      };
                    })
                  (lib.filesystem.listFilesRecursive path)
                );
          };
        };
      # ];
      extraSpecialArgs = specialArgs;
    };

  };
}