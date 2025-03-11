{ config, pkgs, flake, ... }: {
  gui.enable = true;
  hardware.sensor.iio.enable = true; # autorotate

  # musnix.enable = true;
  programs.adb.enable = true;

  networking.firewall.allowedTCPPorts = [
    1716 # gsconnect
  ];

  # TODO: remove after migrating to new btrfs config
  imports = [ ../disks.ext4.nix ];

  services = {
    tailscale = {
      enable = true;
      extraSetFlags = [
        "--ssh"
        # "--exit-node=server"
        "--operator=${flake.lib.username}"
        "--accept-routes"
      ];
    };
    printing.enable = true;
    # effects = {
    #   enable = true;
    #   kernel = "controlC1";
    # };
    xserver.wacom.enable = true;
    udev.packages = [ pkgs.qmk-udev-rules ];
  };

  age = {
    rekey.hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA1UTeWel4Cnb5h8VuGxl0aOmhS0xkHVXAFIltfOaTt0";
    secrets = {
      id_ed25519 = {
        rekeyFile = ./id_ed25519.age;
        path = "${config.users.users.${flake.lib.username}.home}/.ssh/id_ed25519";
        owner = flake.lib.username;
      };

      github = {
        rekeyFile = ./github.age;
        owner = flake.lib.username;
      };

      gitlab = {
        rekeyFile = ./gitlab.age;
        owner = flake.lib.username;
      };
    };
  };

  home-manager.users.${flake.lib.username} = {

    programs.obs-studio = {
      # enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        obs-replay-source
      ];
    };

    home.packages = with pkgs; [
      alsa-utils
      # comms
      element-desktop
      vlc
      obsidian
      xournalpp

      nextcloud-client

      unzip

      # design
      blender
      inkscape
      krita
      prusa-slicer

      # music
      ardour
      # flake.packages.effects
      guitarix
      musescore
      pianobooster
      qjackctl

      # media
      # transmission_4-gtk
      youtube-music
      boatswain
      sonic-pi
      supercollider
    ];

    programs.ssh.matchBlocks = {
      gitlab.identityFile = config.age.secrets.gitlab.path;
      github.identityFile = config.age.secrets.github.path;
    };
  };

}
