{ config, lib, pkgs, ... }:
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
  };

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = true;

  disko.devices = {
    disk.nvme0n1 = {
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
              settings = {
                allowDiscards = true;
                # dd if=/dev/random of=secret.key bs=2048 count=1
                # dd if=secret.key of=/dev/sda
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
