{
  config,
  pkgs,
  flake,
  ...
}:
{
  gui = {
    enable = true;
    keyboard = "/dev/input/by-path/pci-0000:00:14.0-usb-0:1:1.0-event-kbd";
  };
  hardware.sensor.iio.enable = true; # autorotate
  hardware.graphics.extraPackages = [ pkgs.mesa ];

  # programs.adb.enable = true;
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
  };

  networking = {
    search = [ "lan" ];
    firewall.allowedTCPPorts = [
      1716 # gsconnect
      8081 # expo / react-native
    ];
  };

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

    services.nextcloud-client = {
      enable = true;
      startInBackground = true;
    };

    programs = {
      obs-studio = {
        enable = true;
        plugins = with pkgs.obs-studio-plugins; [
          obs-replay-source
        ];
      };
      vscode = {
        profiles.default = {
          extensions = with pkgs.vscode-marketplace; [
            datakurre.devenv
          ];
        };
      };
    };

    home.packages = with pkgs; [
      alsa-utils
      # comms
      xournalpp
      webcamoid
      mpv

      unzip

      # design
      blender
      # TODO: decrease cache misses
      # inkscape
      krita
      prusa-slicer

      # music
      ardour
      # flake.packages.effects
      # guitarix
      musescore
      pianobooster
      qjackctl

      # media
      # transmission_4-gtk
      boatswain
      # sonic-pi
      supercollider

      nextcloud-client
    ];

    programs.ssh.settings = {
      "gitlab.com".IdentityFile = config.age.secrets.gitlab.path;
      "github.com".IdentityFile = config.age.secrets.github.path;
      "router switch ap1 ap2 tower homeassistant" = {
        User = "root";
        SetEnv.TERM = "xterm-256color";
      };
    };
  };

}
