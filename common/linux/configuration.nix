{ pkgs, ... }:
{

  hardware = {
    pulseaudio.enable = false;
    i2c.enable = true;
    sensor.iio.enable = true;
  };

  console = {
    useXkbConfig = true;
  };

  services = {
    xserver = {
      enable = true;
      displayManager = {
        gdm.enable = true;
      };
      libinput = {
        touchpad = {
          tapping = true;
          naturalScrolling = true;
          middleEmulation = false;
        };
      };
    };
    # ddccontrol.enable = true;
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
    printing.enable = true;
    # avahi = {
    #   enable = true;
    #   nssmdns = true;
    # };
    fprintd = {
      enable = true;
    };
    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
      jack.enable = true;
    };
    # globalprotect.enable = true;
    opensnitch.enable = true;
  };

  virtualisation = {
    docker = {
      enable = true;
      enableOnBoot = false;
    };
  };

  sound.enable = true;

  security = {
    sudo.extraRules = [
      {
        users = [ "bryton" ];
        commands = [{ command = "ALL"; options = [ "NOPASSWD" ]; }];
      }
    ];
    pam = {
      services = {
        login = {
          fprintAuth = true;
        };
      };
    };
    rtkit.enable = true;
  };
}
