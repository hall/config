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
    wifi.enable = true;
    xserver.wacom.enable = true;
    udev.packages = [ pkgs.qmk-udev-rules ];
  };

  age = {
    rekey.hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP70uIe/+6FtPWkuA7qiNRAoe2uvY+Qj/zGtU34HOccd";
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
      flake.packages.effects
      guitarix
      musescore
      pianobooster
      qjackctl

    ];

    programs.ssh.matchBlocks = {
      gitlab = {
        host = "gitlab.com";
        user = "git";
        identityFile = config.age.secrets.gitlab.path;
      };
      github = {
        host = "github.com";
        user = "git";
        identityFile = config.age.secrets.github.path;
      };
    };
  };

}
