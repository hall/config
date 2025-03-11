{ flake, config, lib, pkgs, ... }:
let
  name = "gui";
  cfg = config.${name};
in
{
  options.${name} = {
    enable = lib.mkEnableOption "gui-specific settings like displays, styles, etc";
  };

  config = lib.mkIf cfg.enable {
    hardware = {
      graphics.enable = true;
      bluetooth.enable = true;
    };

    fonts.packages = with pkgs; [
      hack-font
      font-awesome
    ];

    stylix = {
      enable = true;
      base16Scheme.palette = {
        base00 = "#2b303b";
        base01 = "#343d46"; # TODO: secondary bg color, needs to be a little less green?
        base02 = "#4f5b66";
        base03 = "#65737e";
        base04 = "#a7adba";
        base05 = "#c0c5ce";
        base06 = "#dfe1e8";
        base07 = "#eff1f5";
        base08 = "#bf616a";
        base09 = "#d08770";
        base0A = "#ebcb8b";
        base0B = "#a3be8c";
        base0C = "#96b5b4";
        base0D = "#8fa1b3";
        base0E = "#b48ead";
        base0F = "#ab7967";
      };
      fonts = {
        serif = config.stylix.fonts.monospace;
        sansSerif = config.stylix.fonts.monospace;
        monospace = {
          package = pkgs.hack-font;
          name = "Hack";
        };
      };
      #targets = {
      #  vscode.profileNames = [ "Default" ];
      #  firefox.profileNames = [ "default" ];
      #};
    };

    home-manager.users.${flake.lib.username} = {
      programs = import ./programs.nix { inherit pkgs flake config lib; };
      services = {
        mako = {
          enable = true;
          # settings = { };
          layer = "overlay";
        };
        wlsunset = {
          enable = true;
          sunrise = "08:00";
          sunset = "20:00";
        };
        swayidle = {
          # enable = true;
          events = [
            { event = "before-sleep"; command = "${pkgs.swaylock}/bin/swaylock -fF"; }
            { event = "lock"; command = "lock"; }
          ];
          timeouts = [
            { timeout = 600; command = "${pkgs.swaylock}/bin/swaylock -fF"; }
            { timeout = 900; command = "${pkgs.systemd}/bin/systemctl suspend"; }
          ];

        };
      };
      home = {
        packages = with pkgs; [
          nixpkgs-fmt
          wl-clipboard
          gnome-sound-recorder
          ddcutil
          gtop
        ];

        sessionVariables = {
          MOZ_USE_XINPUT2 = "1";
          # run firefox natively on wayland
          MOZ_ENABLE_WAYLAND = "1";
        };
      };
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
            # re-bind to circumvent swaynag
            "${modifier}+Shift+e" = "exec sway exit";
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
            { command = "obsidian"; }
            { command = "firefox"; }
          ];
          assigns = {
            "1" = [{ app_id = "obsidian"; }];
            "2" = [{ app_id = "firefox"; }];
            "3" = [{ app_id = "^code"; }];
          };
          workspaceOutputAssign = [
            { workspace = "1"; output = "eDP-1"; }
            { workspace = "2"; output = "Dell Inc. DELL S2721NX HLCBZ13"; }
            { workspace = "3"; output = "Dell Inc. DELL S2721NX 9BZZC23"; }
          ];
          output = {
            eDP-1.pos = "0 0";
            "Dell Inc. DELL S2721NX 9BZZC23".pos = "0 -1080";
            "Dell Inc. DELL S2721NX HLCBZ13" = {
              pos = "-1080 -1080";
              transform = "90";
            };
          };
        };
      };

    };

    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
      wlr = {
        enable = true;
        settings = {
          screencast = {
            output_name = "eDP-1";
            chooser_type = "simple";
            chooser_cmd = "${pkgs.slurp}/bin/slurp -f %o -or";
          };
        };
      };
      config.common.default = "wlr";
      extraPortals = with pkgs; [
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gtk
      ];
    };

    programs = {
      dconf.enable = true;
      light = {
        enable = true;
        brightnessKeys.enable = true;
      };
    };
    services = {
      wifi.enable = true;
      acpid.enable = true;
      # use FDE as password
      getty.autologinUser = flake.lib.username;
      fwupd.enable = true;
      hardware.bolt.enable = true;
      geoclue2.enable = true;
      gnome.gnome-keyring.enable = true;
      actkbd = {
        enable = true;
        bindings =
          let
            wpctl = cmd: "${pkgs.sudo}/bin/sudo -u ${flake.lib.username} env XDG_RUNTIME_DIR=/run/user/1000 ${pkgs.busybox}/bin/sh -c '${pkgs.wireplumber}/bin/wpctl ${cmd}'";
          in
          [
            { keys = [ 190 ]; events = [ "key" ]; command = wpctl "set-mute @DEFAULT_AUDIO_SOURCE@ toggle"; }
            { keys = [ 113 ]; events = [ "key" ]; command = wpctl "set-mute @DEFAULT_AUDIO_SINK@ toggle"; }
            { keys = [ 114 ]; events = [ "key" "rep" ]; command = wpctl "set-volume @DEFAULT_AUDIO_SINK@ 5%- -l 0.0"; }
            { keys = [ 115 ]; events = [ "key" "rep" ]; command = wpctl "set-volume @DEFAULT_AUDIO_SINK@ 5%+ -l 1.0"; }
          ];
      };
      ddccontrol.enable = true;
      upower.enable = true;
      libinput.touchpad.naturalScrolling = true;

      interception-tools = {
        enable = true; # TODO: device-specific activation
        plugins = with pkgs.interception-tools-plugins; [
          caps2esc
        ];
        # https://github.com/NixOS/nixpkgs/issues/126681
        udevmonConfig = with pkgs; ''
          # laptop
          - JOB: "${interception-tools}/bin/intercept -g $DEVNODE | ${interception-tools-plugins.caps2esc}/bin/caps2esc | ${interception-tools}/bin/uinput -d $DEVNODE"
            DEVICE:
              # only target built-in keyboard
              LINK: /dev/input/by-path/pci-0000:00:14.0-usb-0:1:1.0-event-kbd
              EVENTS:
                EV_KEY: [KEY_CAPSLOCK, KEY_ESC]
          # work
          - JOB: "${interception-tools}/bin/intercept -g $DEVNODE | ${interception-tools-plugins.caps2esc}/bin/caps2esc | ${interception-tools}/bin/uinput -d $DEVNODE"
            DEVICE:
              # only target built-in keyboard
              LINK: /dev/input/by-path/platform-i8042-serio-0-event-kbd
              EVENTS:
                EV_KEY: [KEY_CAPSLOCK, KEY_ESC]
        '';
      };
    };

    virtualisation = {
      docker = {
        enable = true;
        enableOnBoot = false;
      };
    };
  };
}
