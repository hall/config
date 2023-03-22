{ flake, pkgs, config, lib, ... }: {
  # $ cat /proc/device-tree/model 
  #   Raspberry Pi 3 Model B+
  # https://www.hifiberry.com/docs/data-sheets/datasheet-miniamp

  nixpkgs.overlays = [
    (_final: prev: {
      deviceTree.applyOverlays = prev.callPackage ../apply-overlays-dtmerge.nix { };
    })
  ];

  monitor.enable = true;

  users.users.${flake.username}.extraGroups = [ "audio" ];

  hardware.deviceTree = {
    enable = true;
    filter = lib.mkForce "*-rpi-3-b-plus.dtb";
    overlays = [{
      name = "hifiberry-dac";
      # https://github.com/raspberrypi/linux/blob/rpi-5.15.y/arch/arm/boot/dts/overlays/hifiberry-dac-overlay.dts
      dtsText = ''
         // Definitions for HiFiBerry DAC
         /dts-v1/;
         /plugin/;

         / {
          compatible = "brcm,bcm2837";

         	fragment@0 {
         		target = <&i2s>;
         		__overlay__ {
         			status = "okay";
         		};
         	};

         	fragment@1 {
         		target-path = "/";
         		__overlay__ {
         			pcm5102a-codec {
         				#sound-dai-cells = <0>;
         				compatible = "ti,pcm5102a";
         				status = "okay";
         			};
         		};
         	};

         	fragment@2 {
         		target = <&sound>;
         		__overlay__ {
         			compatible = "hifiberry,hifiberry-dac";
         			i2s-controller = <&i2s>;
         			status = "okay";
         		};
         	};
        };
      '';
    }];
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_rpi3;
    loader.generic-extlinux-compatible.enable = true;
  };

  services = {
    snapserver = {
      enable = true;
      openFirewall = true;
      streams = {
        all = {
          type = "meta";
          location = "/turntable/spotify";
        };
        turntable = {
          type = "tcp";
          location = "0.0.0.0:49566";
          query = {
            sampleformat = "44100:16:2";
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
    services.snapserver.serviceConfig.EnvironmentFile = "/run/secrets/spotify";
    user.services = {
      snapcast-sink = {
        wantedBy = [ "pipewire.service" ];
        after = [ "pipewire.service" ];
        bindsTo = [ "pipewire.service" ];
        path = with pkgs; [
          gawk
          pulseaudio
        ];
        script = ''
          pactl load-module module-pipe-sink file=/run/snapserver/pipewire sink_name=Snapcast format=s16le rate=48000
        '';
      };

      snapclient = {
        wantedBy = [
          "multi-user.target" # enable on boot
        ];
        after = [
          "pipewire.service"
        ];
        serviceConfig = {
          ExecStart = "${pkgs.snapcast}/bin/snapclient -h ::1";
        };
      };
    };
  };

}
