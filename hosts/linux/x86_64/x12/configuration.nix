{ config, pkgs, musnix, flake, ... }:
{
  boot.binfmt.emulatedSystems = [
    "aarch64-linux"
  ];

  laptop.enable = true;
  hardware.opengl.enable = true;

  musnix.enable = true;
  programs.steam.enable = true;
  # wireguard.enable = true;

  networking = {
    firewall = {
      checkReversePath = "loose";
      allowedTCPPorts = [
        1716 # gsconnect
      ];
      allowedUDPPorts = [
        51820 # wg
      ];
    };
    wg-quick.interfaces.wg0 = {
      address = [ "10.1.0.2/24" ];
      dns = [ "10.0.0.1" ];
      listenPort = 51820;
      privateKeyFile = "/run/secrets/wg";
      peers = [{
        endpoint = "vpn.${flake.hostname}:51820";
        allowedIPs = [ "0.0.0.0/0" ];
        publicKey = "bt2nzOAO+ArOj5KQRI9c5pphmazcCZmiWvo/TeP3n3M=";
        persistentKeepalive = 25;
      }];
    };
    networkmanager.dispatcherScripts = [{
      source = pkgs.writeText "upHook" ''
        export PATH=$PATH:/run/current-system/sw/bin
        # if in range of home network
        if [[ nmcli -t -f SSID device wifi | grep hall ]]; then
          setting=false
        fi
        su -l ${flake.username} -c "dbus-launch dconf write /org/gnome/desktop/screensaver/lock-enabled ''${setting:-true}"
      '';
    }];
  };

  services = {
    printing.enable = true;
    effects = {
      enable = true;
      kernel = "controlC1";
    };
    # wifi.enable = true;
    xserver.wacom.enable = true;
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

  age.secrets = {
    wg.file = ../../../../secrets/wg_${config.networking.hostName}.age;
    id_ed25519 = {
      file = ../../../../secrets/id_ed25519.age;
      path = "${config.users.users.${flake.username}.home}/.ssh/id_ed25519";
      owner = flake.username;
    };

    # openwrt doesn't support ed25519
    id_rsa = {
      file = ../../../../secrets/id_rsa.age;
      path = "${config.users.users.${flake.username}.home}/.ssh/id_rsa";
      owner = flake.username;
    };

    github = {
      file = ../../../../secrets/github.age;
      owner = flake.username;
    };

    gitlab = {
      file = ../../../../secrets/gitlab.age;
      owner = flake.username;
    };

    kubeconfig = {
      file = ../../../../secrets/kubeconfig.age;
      owner = flake.username;
    };

    kubenix = {
      file = ../../../../secrets/kubenix.age;
      owner = flake.username;
    };
  };

}
