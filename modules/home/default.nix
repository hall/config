{ lib, config, flake, specialArgs, ... }:
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
  config = lib.mkIf cfg.enable {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "backup";
      extraSpecialArgs = specialArgs;
      users.${flake.lib.username} = { pkgs, ... }: {
        programs = lib.mkMerge [ (import ./programs { inherit pkgs flake config lib; }) cfg.programs ];
        services = cfg.services;

        stylix.enable = true;

        # TODO: why?
        qt.enable = true;
        gtk.enable = true;

        wayland.windowManager.sway = {
          enable = true;
          xwayland = false;
          config = rec {
            modifier = "Mod4"; # GUI key
            bars = [ ]; # replace w/ waybar
            menu = "${pkgs.tofi}/bin/tofi-run | ${pkgs.findutils}/bin/xargs swaymsg exec --";
            window = {
              border = 0;
              titlebar = false;
            };
            floating.titlebar = false;
            keybindings = with pkgs; lib.mkOptionDefault {
              "${modifier}+p" = "exec ${slurp}/bin/slurp | ${grim}/bin/grim -g - - | ${wl-clipboard}/bin/wl-copy";
            };
            input = {
              "type:touch".map_to_output = "eDP-1";
              "*" = {
                xkb_layout = "us";
                xkb_variant = "dvorak";

                repeat_rate = "50";
                repeat_delay = "200";

                click_method = "clickfinger";
                natural_scroll = "enabled";

                tap = "enabled";
                drag = "enabled";
                drag_lock = "enabled";
                dwt = "enabled"; # disable while typing
              };
            };
            startup = [
              { command = "waybar"; }
              { command = "code"; }
              { command = "logseq"; }
              { command = "firefox"; }
            ];
            assigns = {
              "1: notes" = [{ class = "^Logseq$"; }];
              "2: web" = [{ class = "^Firefox$"; }];
              "3: ide" = [{ class = "^Code$"; }];
            };
            workspaceOutputAssign = [
              { output = "eDP-1"; workspace = "notes"; }
              { output = "DP-6"; workspace = "web"; }
              { output = "DP-5"; workspace = "ide"; }
            ];
            output = {
              eDP-1.pos = "0 0";
              DP-5.pos = "0 -1080";
              DP-6 = {
                pos = "-1080 -1080";
                transform = "90";
              };
            };
          };
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
            # run firefox natively on wayland
            MOZ_ENABLE_WAYLAND = "1";
          };
          file = cfg.file // {
            # ".logseq".source = flake.nixosConfigurations.${}.lib.file.mkOutOfStoreSymlink "/home/${flake.lib.username}/notes/data";
          };
        };
      };

    };
  };
}
