{ pkgs, mach, ... }:
let
  xontribs = [
    # "argcomplete" # tab completion of python and xonsh scripts
    # "sh" # prefix (ba)sh commands with "!"
    # "autojump" or "z"   # autojump support(or zoxide?)
    # "autoxsh" or "direnv"     # execute .autoxsh when entering directory
    # "onepath" # act on file/dir by only using its name
    # "prompt_starship"
    # "pipeliner" # use "pl" to pipe a python expression
  ];

  # pyenv = mach.mkPython {
  #   requirements = ''
  #     black
  #     python-lsp-server[all]
  #     xontrib-sh
  #     xxh-xxh
  #     numpy
  #     pandas
  #   ''; #+ builtins.toString (map (x: "xontrib-" + x) xontribs);
  #   # pylint
  #   # pip
  # };

  # _xonsh = pkgs.xonsh.overrideAttrs (old: {
  #   propagatedBuildInputs = old.propagatedBuildInputs ++ pyenv.python.pkgs.selectPkgs pyenv.python.pkgs;
  # });

in
{
  imports = [
    ./hardware.nix
  ];

  # boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # musnix.enable = true;
  hardware = {
    pulseaudio.enable = false;
    i2c.enable = true;
    sensor.iio.enable = true;
  };


  networking = {
    firewall = {
      # enable = false;
      allowedTCPPorts = [
        1716 # gsconnect
        24800 # barrier
        # 5900 # vnc
      ];
    };
    wireguard = {
      enable = true;
      # interfaces = {
      #   wg0 = {
      #     # TODO: use privateKeyFile instead
      #     privateKey = builtins.exec [ "su" "-c" "echo -n 'rbw get wg | tr -d '\\n'" "bryton" ];
      #     ips = [
      #       "192.168.20.4/24"
      #     ];
      #     peers = [{
      #       endpoint = "vpn.bryton.io";
      #       publicKey = "jTmdPNGrlmF3vS/AdLNiWCK4HfA1EeeogR8yCHLsgWk=";
      #     }];
      #   };

      # };
    };
    networkmanager = {
      dispatcherScripts = [{
        type = "basic";
        source = pkgs.writeText "upHook" ''
          export PATH=$PATH:/run/current-system/sw/bin
                if [[ "$(nmcli -t -f NAME connection show --active)" == "hall" ]]; then
                  setting=false
                fi
                su -l bryton -c "dbus-launch dconf write /org/gnome/desktop/screensaver/lock-enabled ''${setting:-true}"
        '';
      }];
    };
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
        - JOB: "${interception-tools}/bin/intercept -g $DEVNODE | ${interception-tools-plugins.caps2esc}/bin/caps2esc | ${interception-tools}/bin/uinput -d $DEVNODE"
          DEVICE:
            # only target built-in keyboard
            LINK: /dev/input/by-path/pci-0000:00:14.0-usb-0:1:1.0-event-kbd
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

    udev = {
      extraRules = ''
        # Atmel DFU
        ### ATmega16U2
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="2fef", TAG+="uaccess"
        ### ATmega32U2
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="2ff0", TAG+="uaccess"
        ### ATmega16U4
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="2ff3", TAG+="uaccess"
        ### ATmega32U4
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="2ff4", TAG+="uaccess"
        ### AT90USB64
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="2ff9", TAG+="uaccess"
        ### AT90USB162
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="2ffa", TAG+="uaccess"
        ### AT90USB128
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="2ffb", TAG+="uaccess"

        # Input Club
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="1c11", ATTRS{idProduct}=="b007", TAG+="uaccess"

        # STM32duino
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="1eaf", ATTRS{idProduct}=="0003", TAG+="uaccess"
        # STM32 DFU
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", TAG+="uaccess"

        # BootloadHID
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="05df", TAG+="uaccess"

        # USBAspLoader
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="05dc", TAG+="uaccess"

        # ModemManager should ignore the following devices
        # Atmel SAM-BA (Massdrop)
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="6124", TAG+="uaccess", ENV{ID_MM_DEVICE_IGNORE}="1"

        # Caterina (Pro Micro)
        ## pid.codes shared PID
        ### Keyboardio Atreus 2 Bootloader
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="1209", ATTRS{idProduct}=="2302", TAG+="uaccess", ENV{ID_MM_DEVICE_IGNORE}="1"
        ## Spark Fun Electronics
        ### Pro Micro 3V3/8MHz
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="1b4f", ATTRS{idProduct}=="9203", TAG+="uaccess", ENV{ID_MM_DEVICE_IGNORE}="1"
        ### Pro Micro 5V/16MHz
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="1b4f", ATTRS{idProduct}=="9205", TAG+="uaccess", ENV{ID_MM_DEVICE_IGNORE}="1"
        ### LilyPad 3V3/8MHz (and some Pro Micro clones)
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="1b4f", ATTRS{idProduct}=="9207", TAG+="uaccess", ENV{ID_MM_DEVICE_IGNORE}="1"
        ## Pololu Electronics
        ### A-Star 32U4
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="1ffb", ATTRS{idProduct}=="0101", TAG+="uaccess", ENV{ID_MM_DEVICE_IGNORE}="1"
        ## Arduino SA
        ### Leonardo
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="2341", ATTRS{idProduct}=="0036", TAG+="uaccess", ENV{ID_MM_DEVICE_IGNORE}="1"
        ### Micro
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="2341", ATTRS{idProduct}=="0037", TAG+="uaccess", ENV{ID_MM_DEVICE_IGNORE}="1"
        ## Adafruit Industries LLC
        ### Feather 32U4
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="239a", ATTRS{idProduct}=="000c", TAG+="uaccess", ENV{ID_MM_DEVICE_IGNORE}="1"
        ### ItsyBitsy 32U4 3V3/8MHz
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="239a", ATTRS{idProduct}=="000d", TAG+="uaccess", ENV{ID_MM_DEVICE_IGNORE}="1"
        ### ItsyBitsy 32U4 5V/16MHz
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="239a", ATTRS{idProduct}=="000e", TAG+="uaccess", ENV{ID_MM_DEVICE_IGNORE}="1"
        ## dog hunter AG
        ### Leonardo
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="2a03", ATTRS{idProduct}=="0036", TAG+="uaccess", ENV{ID_MM_DEVICE_IGNORE}="1"
        ### Micro
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="2a03", ATTRS{idProduct}=="0037", TAG+="uaccess", ENV{ID_MM_DEVICE_IGNORE}="1"

        # hid_listen
        KERNEL=="hidraw*", MODE="0660", GROUP="plugdev", TAG+="uaccess", TAG+="udev-acl"

        # hid bootloaders
        ## QMK HID
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="2067", TAG+="uaccess"
        ## PJRC's HalfKay
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="0478", TAG+="uaccess"
      '';
    };
  };

  virtualisation = {
    docker = {
      enable = true;
      enableOnBoot = false;
    };
  };

  sound.enable = true;

  environment = {
    systemPackages = with pkgs; [
      # pyenv
    ];
  };

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
