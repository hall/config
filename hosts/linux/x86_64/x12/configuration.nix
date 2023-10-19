{ config, pkgs, musnix, flake, ... }: {
  laptop.enable = true;
  hardware = {
    opengl.enable = true;
    # autorotate
    sensor.iio.enable = true;
  };

  musnix.enable = true;

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
    tailscale.enable = true;
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
      logseq
      deploy-rs
      zotero
      transmission-gtk
      foliate
      okular
      jellyfin-media-player
      carla

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
      endeavour # todo
      yt-dlp
      bitwarden-cli
      siglo
      moserial
      cachix
      koreader

      watchmate
      nix-diff
      gnome.nautilus # files
      gnome.totem # video
      gnome.cheese
      vlc
      baobab # disk usage
    ] ++ (with flake.packages; [
      effects
    ]);
  };

}
