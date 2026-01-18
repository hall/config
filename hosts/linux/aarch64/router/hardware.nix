# Raspberry Pi 4 Hardware Configuration
{ modulesPath, ... }: {
  imports = [
    (modulesPath + "/profiles/base.nix")
  ];

  fileSystems."/boot/firmware" = {
    device = "/dev/disk/by-label/FIRMWARE";
    fsType = "vfat";
    options = [ "noatime" ];
  };

  boot = {
    initrd.availableKernelModules = [
      "usbhid"
      "usb_storage"
      "uas"           # USB Attached SCSI for better SSD performance
      "vc4"
      "bcm2835_dma"
      "i2c_bcm2835"
    ];

    kernelParams = [
      "console=ttyS0,115200n8"
      "console=tty0"
      "cma=128M" # GPU memory
    ];

    initrd.services.lvm.enable = false;

    # USB Ethernet adapter support
    kernelModules = [
      "r8152"         # Realtek USB Ethernet (common)
      "asix"          # ASIX USB Ethernet
      "ax88179_178a"  # ASIX AX88179
      "cdc_ether"     # Generic CDC Ethernet
      "cdc_ncm"
      "smsc95xx"      # Built-in ethernet on Pi
    ];
  };

  services.fstrim = {
    enable = true;
    interval = "weekly";
  };

  nixpkgs.hostPlatform = "aarch64-linux";
}
