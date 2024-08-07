{ config, pkgs, flake, ... }: {
  laptop.enable = true;
  hardware = {
    graphics.enable = true;
    sensor.iio.enable = true; # autorotate
  };

  # musnix.enable = true;
  programs.adb.enable = true;

  networking.firewall.allowedTCPPorts = [
    1716 # gsconnect
  ];

  services = {
    # tailscale = {
    #   enable = true;
    #   extraUpFlags = [ "--ssh" ];
    # };
    printing.enable = true;
    # effects = {
    #   enable = true;
    #   kernel = "controlC1";
    # };
    wifi.enable = true;
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

  home = {
    enable = true;
    packages = with pkgs; [
      # comms
      element-desktop
      logseq
      xournalpp
      google-chrome

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
      obs-studio
      sonic-pi
      supercollider
    ];

    programs.ssh.matchBlocks = {
      gitlab.identityFile = config.age.secrets.gitlab.path;
      github.identityFile = config.age.secrets.github.path;
    };
  };

}
