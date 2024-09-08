{ flake, config, lib, pkgs, ... }:
let
  name = "laptop";
  cfg = config.${name};
in
{
  options.${name} = {
    enable = lib.mkEnableOption "laptop-specific settings like disk encryption";
  };
  config = lib.mkIf cfg.enable {
    hardware = {
      graphics.enable = true;
      bluetooth.enable = true;
    };

    xdg.portal.config.common.default = "wlr";

    environment.systemPackages = with pkgs;[
      dunst
      wmenu
      foot
      waylock
    ];

    programs = {
      dconf.enable = true;
      light = {
        enable = true;
        brightnessKeys.enable = true;
      };
    };
    services = {
      actkbd = {
        enable = true;
        bindings =
          let
            wpctl = cmd: "${pkgs.sudo}/bin/sudo -u ${flake.lib.username} env XDG_RUNTIME_DIR=/run/user/1000 ${pkgs.busybox}/bin/sh -c '${pkgs.wireplumber}/bin/wpctl ${cmd} && ${pkgs.sox}/bin/play -q -n synth 0.05 sin 400'";
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
