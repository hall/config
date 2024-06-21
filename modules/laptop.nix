{ config, lib, pkgs, ... }:
let
  name = "laptop";
  cfg = config.${name};
in
{
  options.${name} = {
    enable = lib.mkEnableOption "laptop-specific settings like disk encryption";
  };
  config = lib.mkIf cfg.enable {
    hardware.bluetooth.enable = true;

    environment.systemPackages = with pkgs;[
      # utitilies
      baobab # disk usage
      gnome.nautilus # files
      gnome.totem # video
      gnome.file-roller # archive
      dpkg
    ];

    programs.dconf.enable = true;
    services = {
      ddccontrol.enable = true;
      xserver = {
        enable = true;
        desktopManager.gnome.enable = true;
        displayManager.gdm.enable = true;
      };
      libinput = {
        touchpad = {
          tapping = true;
          naturalScrolling = true;
          middleEmulation = false;
        };
      };
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
