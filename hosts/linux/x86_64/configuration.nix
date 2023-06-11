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
      kernelModules = [ "dm-snapshot" ];
      verbose = false;
    };
    kernelParams = [ "quiet" ]; #"udev.log_priority=3"
    kernelModules = [ "kvm-intel" ];
  };


  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-label/boot";
      fsType = "vfat";
    };
  };
  swapDevices = [{
    device = "/dev/disk/by-label/swap";
  }];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = true;
}
