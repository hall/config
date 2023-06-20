{ config, pkgs, musnix, flake, ... }: {
  laptop.enable = true;
  hardware = {
    opengl.enable = true;
    # autorotate
    sensor.iio.enable = true;
  };

  musnix.enable = true;
  # wireguard.enable = true;

  networking = {
    firewall = {
      # checkReversePath = "loose";
      allowedTCPPorts = [
        1716 # gsconnect
      ];
      allowedUDPPorts = [
        51820 # wg
      ];
    };
    # wg-quick.interfaces.wg0 = {
    #   address = [ "10.1.0.2/24" ];
    #   dns = [ "10.0.0.1" ];
    #   listenPort = 51820;
    #   privateKeyFile = "/run/secrets/wg";
    #   peers = [{
    #     endpoint = "vpn.${flake.lib.hostname}:51820";
    #     allowedIPs = [ "0.0.0.0/0" ];
    #     publicKey = "bt2nzOAO+ArOj5KQRI9c5pphmazcCZmiWvo/TeP3n3M=";
    #     persistentKeepalive = 25;
    #   }];
    # };
    networkmanager.dispatcherScripts = [{
      source = pkgs.writeText "upHook" ''
        export PATH=$PATH:/run/current-system/sw/bin
        # if in range of home network
        if [[ nmcli -t -f SSID device wifi | grep hall ]]; then
          setting=false
        fi
        su -l ${flake.lib.username} -c "dbus-launch dconf write /org/gnome/desktop/screensaver/lock-enabled ''${setting:-true}"
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
    udev.packages = [ pkgs.qmk-udev-rules ];
  };

  age.secrets = {
    wg.file = ../../../../secrets/wg_${config.networking.hostName}.age;
    id_ed25519 = {
      file = ../../../../secrets/id_ed25519.age;
      path = "${config.users.users.${flake.lib.username}.home}/.ssh/id_ed25519";
      owner = flake.lib.username;
    };

    # openwrt doesn't support ed25519
    id_rsa = {
      file = ../../../../secrets/id_rsa.age;
      path = "${config.users.users.${flake.lib.username}.home}/.ssh/id_rsa";
      owner = flake.lib.username;
    };

    github = {
      file = ../../../../secrets/github.age;
      owner = flake.lib.username;
    };

    gitlab = {
      file = ../../../../secrets/gitlab.age;
      owner = flake.lib.username;
    };

    kubeconfig = {
      file = ../../../../secrets/kubeconfig.age;
      owner = flake.lib.username;
    };

    kubenix = {
      file = ../../../../secrets/kubenix.age;
      owner = flake.lib.username;
    };
  };

  home = {
    enable = true;
    # TODO: required for secrets module
    # programs.rbw = {
    #   enable = true;
    #   settings = {
    #     inherit (flake.lib) email;
    #     pinentry = "gtk2"; # gnome3
    #   };
    # };

    packages = with pkgs; [
      carla
      deploy-rs
      zotero
      transmission-gtk
      foliate
      okular

      pianobooster
      qjackctl
      #faust
      #faustlive
      #gimp
      #siril
      ardour
      calibre
      guitarix
      inkscape
      krita
      blender
      musescore
      prusa-slicer
      xournalpp
      element-desktop
      gnome.gnome-boxes

      wireshark

      talosctl
      newsflash
      sof-firmware
      gnome.gnome-todo
      yt-dlp
      bitwarden-cli
      siglo
      moserial
      cachix
      koreader

      watchmate
      nix-diff
    ] ++ (with flake.packages; [
      effects
    ]);
  };

}
