{ config, pkgs, musnix, flake, ... }: {
  laptop.enable = true;
  hardware = {
    opengl.enable = true;
    sensor.iio.enable = true; # autorotate
  };

  musnix.enable = true;
  programs.adb.enable = true;

  networking.firewall.allowedTCPPorts = [
    1716 # gsconnect
  ];

  services = {
    # tailscale.enable = true;
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

    github = {
      file = ../../../../secrets/github.age;
      owner = flake.lib.username;
    };

    gitlab = {
      file = ../../../../secrets/gitlab.age;
      owner = flake.lib.username;
    };
  };

  home = {
    enable = true;
    packages = with pkgs; [
      # comms
      element-desktop
      logseq
      xournalpp

      # design
      blender
      inkscape
      krita
      prusa-slicer

      # music
      ardour
      flake.packages.effects
      guitarix
      musescore
      pianobooster
      qjackctl

      # utitilies
      baobab # disk usage
      gnome.cheese # webcam
      gnome.nautilus # files
      gnome.totem # video
    ];
  };

}
