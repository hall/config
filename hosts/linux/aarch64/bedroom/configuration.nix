{ lib, flake, pkgs, config, modulesPath, ... }: {

  imports = [
    flake.inputs.hardware.nixosModules.raspberry-pi-4
    (modulesPath + "/installer/sd-card/sd-image-aarch64.nix")
  ];

  monitor.enable = true;
  boot = {
    kernelPackages = lib.mkForce pkgs.linuxPackages_rpi4; # _6_1
    loader.generic-extlinux-compatible.enable = true;
    # > cat /proc/asound/modules
    extraModprobeConfig = ''
      options snd slots=snd_soc_rpi_simple_soundcard
    '';
  };

  users.users.${flake.lib.username}.extraGroups = [ "audio" ];
  users.users."snapserver" = {
    isSystemUser = true;
    group = "snapserver";
    extraGroups = [ "audio" ];
  };
  users.groups.snapserver = { };
  environment.systemPackages = with pkgs;[
    alsa-utils
    dconf
  ];

  hardware = {
    pulseaudio.enable = lib.mkForce true;
    raspberry-pi."4".apply-overlays-dtmerge.enable = true;
    deviceTree = {
      enable = true;
      filter = "bcm2711-rpi-4-b*.dtb";
      overlays = [{
        # https://www.hifiberry.com/docs/data-sheets/datasheet-miniamp
        name = "hifiberry-dac";
        dtsText = with builtins; replaceStrings [ "bcm2835" ] [ "bcm2711" ] (readFile (fetchurl {
          url = "https://raw.githubusercontent.com/raspberrypi/linux/rpi-6.1.y/arch/arm/boot/dts/overlays/hifiberry-dac-overlay.dts";
          sha256 = "0ln9bdwyq9cx3nsn091wmy6a3ydqdnfqagg39v4qbpf6nik2v9fb";
        }));
      }];
    };
  };

  services = {
    pipewire = {
      enable = lib.mkForce false;
      systemWide = true;
    };
    snapserver = {
      enable = true;
      openFirewall = true;
      streams = {
        all = {
          type = "meta";
          location = "/turntable/spotify";
        };
        turntable = {
          type = "alsa";
          location = "/";
          query = {
            device = "hw:2";
            sampleformat = "48000:16:2";
            idle_threshold = "1000"; # ms
          };
        };
        spotify = {
          type = "librespot";
          location = "${pkgs.librespot}/bin/librespot";
          query = {
            name = "spotify";
            devicename = "home";
            volume = "60";
          };
        };
      };
    };
  };

  age.secrets.spotify.file = ../../../../secrets/spotify.age;

  systemd = {
    services = {
      snapserver.serviceConfig.EnvironmentFile = "/run/secrets/spotify";
      snapclient = {
        wantedBy = [ "multi-user.target" ]; # enable on boot
        requires = [ "dbus.service" ];
        wants = [ "avahi-daemon.service" ];
        after = [
          "network-online.target"
          "time-sync.target"
          "sound.target"
          "avahi-daemon.service"
          "pipewire.service"
        ];
        # for alsa device access
        environment.XDG_RUNTIME_DIR = "/run/user/1000";
        serviceConfig = {
          User = flake.lib.username;
          Group = "audio";
          ExecStart = "${pkgs.snapcast}/bin/snapclient -h ::1";
          Restart = "on-failure";
        };
      };
    };
  };
}
