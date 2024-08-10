{ config, ... }:
{
  boot = {
    consoleLogLevel = 0;
    loader = {
      systemd-boot.enable = true;
      generic-extlinux-compatible.enable = false;
    };
    initrd = {
      availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usbhid" "ahci" "rtsx_pci_sdmmc" ];
      kernelModules = [ "dm-snapshot" "usb_storage" ];
      verbose = false;
    };
    kernelParams = [ "quiet" ]; #"udev.log_priority=3"
    kernelModules = [ "kvm-intel" ];
    # kernelPackages = pkgs.linuxPackages_latest;
  };

  # powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = true;

  disko.devices = {
    disk.main = {
      type = "disk";
      device = "/dev/nvme0n1";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "500M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          luks = {
            size = "100%";
            content = {
              type = "luks";
              name = "crypt";
              additionalKeyFiles = [ config.age.secrets.luks.path ];
              settings = {
                # dd if=/dev/random of=/dev/sda bs=2048 count=1
                keyFile = "/dev/sda";
                keyFileSize = 2048;
                fallbackToPassword = true;
              };
              content = {
                type = "lvm_pv";
                vg = "pool";
              };
            };
          };
        };
      };
    };
    lvm_vg.pool = {
      type = "lvm_vg";
      lvs = {
        swap = {
          size = "16G";
          content.type = "swap";
        };
        root = {
          size = "100%FREE";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };
      };
    };
  };
}
