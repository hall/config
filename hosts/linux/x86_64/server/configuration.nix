# NUC11PAHi7, 88:AE:DD:05:C9:46, F2 and/or ESC to enter bios
# TODO
# - circadian lighting
# - connect
#   - switches: https://www.indiegogo.com/projects/mmwave-smart-switch-with-presence-sensing-radar
#   - led controllers
#   - konnected: https://www.reddit.com/r/konnected/comments/15pom5f/any_update_on_matter_support/
#   - power monitoring?
#   - mailbox?
{ lib, pkgs, flake, config, ... }: {
  boot = {
    # TODO: remove? no longer have any aarch64 targets
    # binfmt.emulatedSystems = [ "aarch64-linux" ];
    # for 8bitdo pro 2 in switch mode
    blacklistedKernelModules = [ "hid-nintendo" ];
  };

  nixpkgs.config.packageOverrides = pkgs: {
    intel-vaapi-driver = pkgs.intel-vaapi-driver.override { enableHybridCodec = true; };
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };
  hardware = {
    xpadneo.enable = true;
    steam-hardware.enable = true;
    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver # LIBVA_DRIVER_NAME=iHD
        vaapiVdpau
        intel-compute-runtime
        vpl-gpu-rt
        libvdpau-va-gl
        vpl-gpu-rt
      ];
    };
  };
  environment.sessionVariables = {
    # Force intel-media-driver
    LIBVA_DRIVER_NAME = "iHD";
    # KODI_AE_SINK = "PULSE";
  };

  imports = [
    ./home
    ./media
    ./kodi.nix
    ./backup
    ./gaming.nix
    ./networking
    flake.inputs.hardware.nixosModules.intel-nuc-8i7beh
    ../disks.btrfs.nix
  ];

  networking = {
    firewall = {
      allowedTCPPorts = [
        80 # http redirect
        443 # https
        53 # dns fallback
        8080 # kodi
        5900 # vnc
      ];
      allowedUDPPorts = [
        53 # dns
        67 # dhcp
        68 # dhcp
        9777 # kodi event server
      ];
    };
  };

  age.rekey.hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGOxaUk80jfFnvezJw5J34OdAIC1/fBhZXFeaC/x9Bl1";

  systemd = {
    targets = {
      sleep.enable = false;
      suspend.enable = false;
      hibernate.enable = false;
      hybrid-sleep.enable = false;
    };
    services = {
      "getty@tty1".enable = false;
      "autovt@tty1".enable = false;
    };
  };
  environment.persistence."/persist" = {
    # hideMounts = true;
    directories =
      # config.services.restic.backups.remote.paths ++
      [
        "/var/lib/media"
        "/var/lib/nixos" # uid/gid mappings

        # TODO: transmissions doesn't start w/o this directory
        "/var/lib/media/downloads/incomplete"

        {
          directory = "/etc/home-assistant";
          user = "hass";
          group = "hass";
        }

        # TODO: pull from restic
        "/var/lib/kodi"
        "/var/lib/sonarr"
        "/var/lib/radarr"
        "/var/lib/lidarr"
        "/var/lib/prowlarr"
        "/var/lib/jellyfin"
        "/var/lib/jellyseerr"
        "/var/lib/postgresql"
      ];
    # files = [
    #   "/etc/home-assistant/automations.yaml"
    # ];
  };

  services = {
    stash = {
      enable = true;
      user = flake.lib.username;
      group = "syncthing";
    };
    syncthing.settings.folders.stash.path = lib.mkForce "/var/lib/stash";
  };
}
