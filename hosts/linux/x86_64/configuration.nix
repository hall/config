{ config, lib, pkgs, ... }:
{
  boot = {
    kernelPackages = pkgs.linuxPackages_5_19;
    # extraModulePackages = with config.boot.kernelPackages; [ wireguard ];
    #extraModprobeConfig = ''
    #  options snd-intel-dspcfg dsp_driver=3
    #'';

    consoleLogLevel = 0;
    loader = {
      timeout = lib.mkForce 0; # set to 10 in isoImage
      systemd-boot.enable = true;
      generic-extlinux-compatible.enable = false;
    };
    initrd = {
      availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usbhid" "ahci" "rtsx_pci_sdmmc" ];
      kernelModules = [ "dm-snapshot" ];
      verbose = false;
    };
    kernelParams = [ "quiet" ]; #"udev.log_priority=3" ];
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
    # "/nix/store" = {
    #   device = "/nix/store";
    #   fsType = "none";
    #   options = [ "bind" ];
    # };
  };
  swapDevices = [{
    device = "/dev/disk/by-label/swap";
  }];

  # nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
