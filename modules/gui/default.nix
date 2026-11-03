{ flake, config, lib, pkgs, ... }:
let
  name = "gui";
  cfg = config.${name};
in
{
  imports = [
    ./brightness-sync.nix
    ./login.nix
    ./sway.nix
  ];

  options.${name} = {
    enable = lib.mkEnableOption "gui-specific settings like displays, styles, etc";
  };

  config = lib.mkIf cfg.enable {
    environment.pathsToLink = [ "/share/xdg-desktop-portal" "/share/applications" ];
    environment.systemPackages = [ pkgs.xdg-utils ];
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
      enableReleaseChecks = false;
      base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-frappe.yaml";
      polarity = "dark";
      fonts = {
        serif = config.stylix.fonts.monospace;
        sansSerif = config.stylix.fonts.monospace;
        monospace = {
          package = pkgs.hack-font;
          name = "Hack";
        };
      };
    };

    home-manager.users.${flake.lib.username} = {
      programs = import ./programs.nix { inherit pkgs flake config lib; };
      # waybar's wireplumber module doesn't reconnect if pipewire restarts
      # (e.g. on switch), leaving the volume indicator stale; restart with it
      systemd.user.services.waybar.Unit = {
        PartOf = [ "pipewire.service" ];
        After = [ "pipewire.service" ];
      };
      services = {
        mako = {
          enable = true;
          # settings.layer = "overlay";
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
          BROWSER = "firefox";
        };

        # satty's --output-filename needs this to already exist
        file."Pictures/Screenshots/.keep".text = "";
      };
      xdg.mimeApps = {
        enable = true;
        defaultApplications = {
          "text/html" = "firefox.desktop";
          "x-scheme-handler/http" = "firefox.desktop";
          "x-scheme-handler/https" = "firefox.desktop";
          "x-scheme-handler/about" = "firefox.desktop";
          "x-scheme-handler/unknown" = "firefox.desktop";
        };
      };
      # force: pre-existing mimeapps.list files (written imperatively by
      # apps like Chrome) would otherwise block activation
      xdg.configFile."mimeapps.list".force = true;
      xdg.dataFile."applications/mimeapps.list".force = true;
      stylix = {
        enable = true;
        targets = {
          vscode.profileNames = [ "default" ];
          firefox.profileNames = [ "default" ];
          obsidian.vaultNames = [ "notes" ];
        };
      };

      # TODO: why? (for krita debug)
      qt.enable = true;
      gtk.enable = true;
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
    };
    services = {
      wifi.enable = true;
      acpid.enable = true;
      fwupd.enable = true;
      hardware.bolt.enable = true;
      geoclue2.enable = true;
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
