{ config, lib, pkgs, modulesPath, ... }:
let
  name = "laptop";
  cfg = config.${name};
in
{
  options.${name} = {
    enable = lib.mkEnableOption "laptop-specific settings like disk encryption";
  };
  config = lib.mkIf cfg.enable {
    boot.initrd.luks.devices."crypt".device = "/dev/disk/by-partlabel/crypt";

    hardware.bluetooth.enable = true;
    networking.networkmanager.enable = true;

    fileSystems."/" = lib.mkForce {
      device = "/dev/vg/root";
      fsType = "ext4";
    };
    swapDevices = lib.mkForce [{
      device = "/dev/vg/swap";
    }];

    qt = {
      enable = true;
      style = "adwaita-dark";
      platformTheme = "gnome";
    };

    programs.dconf.enable = true;
    services = {
      ddccontrol.enable = true;
      xserver = {
        enable = true;
        desktopManager.gnome.enable = true;
        displayManager.gdm.enable = true;
        libinput = {
          touchpad = {
            tapping = true;
            naturalScrolling = true;
            middleEmulation = false;
          };
        };
      };
      interception-tools = {
        enable = true; # TODO: device-specific activation
        plugins = with pkgs.interception-tools-plugins; [
          caps2esc
        ];
        # https://github.com/NixOS/nixpkgs/issues/126681
        udevmonConfig = with pkgs; ''
          # x12
          - JOB: "${interception-tools}/bin/intercept -g $DEVNODE | ${interception-tools-plugins.caps2esc}/bin/caps2esc | ${interception-tools}/bin/uinput -d $DEVNODE"
            DEVICE:
              # only target built-in keyboard
              LINK: /dev/input/by-path/pci-0000:00:14.0-usb-0:1:1.0-event-kbd
              EVENTS:
                EV_KEY: [KEY_CAPSLOCK, KEY_ESC]
          # rigetti
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
