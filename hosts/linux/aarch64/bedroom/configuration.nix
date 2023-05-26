{ lib, flake, pkgs, config, ... }: {
  # $ cat /proc/device-tree/model 
  #   Raspberry Pi 3 Model B
  # https://www.hifiberry.com/docs/data-sheets/datasheet-amp2

  nixpkgs.overlays = [
    (_final: prev: {
      deviceTree.applyOverlays = prev.callPackage ../apply-overlays-dtmerge.nix { };
    })
  ];

  monitor.enable = true;

  users.users.${flake.lib.username}.extraGroups = [ "audio" ];

  hardware.deviceTree = {
    enable = true;
    filter = lib.mkForce "*-rpi-3-b.dtb";
    overlays = [
      # {
      #   name = "hifiberry-dacplus";
      #   dtboFile = "${config.boot.kernelPackages.kernel}/dtbs/overlays/hifiberry-dacplus.dtbo";
      # }
      {
        name = "hifiberry-dacplus";
        # https://github.com/raspberrypi/linux/blob/rpi-5.15.y/arch/arm/boot/dts/overlays/hifiberry-dacplus-overlay.dts
        dtsText = ''
          // Definitions for HiFiBerry DAC+
          /dts-v1/;
          /plugin/;

          / {
          	compatible = "brcm,bcm2837";

          	fragment@0 {
          		target-path = "/";
          		__overlay__ {
          			dacpro_osc: dacpro_osc {
          				compatible = "hifiberry,dacpro-clk";
          				#clock-cells = <0>;
          			};
          		};
          	};

          	fragment@1 {
          		target = <&i2s>;
          		__overlay__ {
          			status = "okay";
          		};
          	};

          	fragment@2 {
          		target = <&i2c1>;
          		__overlay__ {
          			#address-cells = <1>;
          			#size-cells = <0>;
          			status = "okay";

          			pcm5122@4d {
          				#sound-dai-cells = <0>;
          				compatible = "ti,pcm5122";
          				reg = <0x4d>;
          				clocks = <&dacpro_osc>;
          				AVDD-supply = <&vdd_3v3_reg>;
          				DVDD-supply = <&vdd_3v3_reg>;
          				CPVDD-supply = <&vdd_3v3_reg>;
          				status = "okay";
          			};
          			hpamp: hpamp@60 {
          				compatible = "ti,tpa6130a2";
          				reg = <0x60>;
          				status = "disabled";
          			};
          		};
          	};

          	fragment@3 {
          		target = <&sound>;
          		hifiberry_dacplus: __overlay__ {
          			compatible = "hifiberry,hifiberry-dacplus";
          			i2s-controller = <&i2s>;
          			status = "okay";
          		};
          	};

          	__overrides__ {
          		24db_digital_gain =
          			<&hifiberry_dacplus>,"hifiberry,24db_digital_gain?";
          		slave = <&hifiberry_dacplus>,"hifiberry-dacplus,slave?";
          		leds_off = <&hifiberry_dacplus>,"hifiberry-dacplus,leds_off?";
          	};
          };
        '';
      }
    ];
  };

  boot = {
    kernelPackages = lib.mkForce pkgs.linuxPackages_rpi3;
    loader.generic-extlinux-compatible.enable = true;
  };

  systemd.services.snapclient = {
    wantedBy = [
      "multi-user.target" # enable on boot
    ];
    after = [
      "pipewire.service"
    ];
    serviceConfig = {
      ExecStart = "${pkgs.snapcast}/bin/snapclient -h office";
    };
  };

}
