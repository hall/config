{ pkgs, system, inputs, flake, ... }:
let
  #pyenv = inputs.mach.mkPython {
  #  requirements = ''
  #    # black
  #    # python-lsp-server[all]
  #    xontrib-sh
  #    # xxh-xxh
  #    # numpy
  #    # pandas
  #  ''; #+ builtins.toString (map (x: "xontrib-" + x) xontribs);
  #  # pylint
  #  # pip
  #};

  #_xonsh = pkgs.xonsh.overrideAttrs (old: {
  #  propagatedBuildInputs = old.propagatedBuildInputs ++ pyenv.python.pkgs.selectPkgs pyenv.python.pkgs;
  #});

in
{

  networking = {
    # wireless.enable = true;
    networkmanager.enable = true;
  };

  hardware.bluetooth.enable = true;

  imports = [
    ./hardware.nix
    # "${flake.inputs.nixpkgs}/nixos/modules/installer/cd-dvd/iso-image.nix"
  ];

  services = {
    # input-remapper.enable = true;
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
    # avahi = {
    #   enable = true;
    #   nssmdns = true;
    # };
    # globalprotect.enable = true;
    opensnitch.enable = true;
  };

  virtualisation = {
    docker = {
      enable = true;
      enableOnBoot = false;
    };
  };
}
