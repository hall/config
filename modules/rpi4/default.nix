# Raspberry Pi 4 shared hardware configuration
{ modulesPath, lib, config, ... }: {
  options.hardware.rpi4.enable = lib.mkEnableOption "Raspberry Pi 4 hardware support";

  imports = [
    (modulesPath + "/profiles/base.nix")
  ];

  config = lib.mkIf config.hardware.rpi4.enable {
    fileSystems."/boot/firmware" = {
      device = "/dev/disk/by-label/FIRMWARE";
      fsType = "vfat";
      options = [ "noatime" ];
    };

    boot = {
      initrd.availableKernelModules = [
        "usbhid"
        "usb_storage"
        "uas"
        "vc4"
        "bcm2835_dma"
        "i2c_bcm2835"
      ];

      kernelParams = [
        "console=ttyS0,115200n8"
        "console=tty0"
        "cma=128M"
      ];

      initrd.services.lvm.enable = false;
    };

    services.fstrim = {
      enable = true;
      interval = "weekly";
    };

    zramSwap = {
      enable = true;
      memoryPercent = 50;
    };

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
  };
}
