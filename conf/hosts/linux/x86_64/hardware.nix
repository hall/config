{ config, lib, pkgs, modulesPath, ... }:
{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot = {
    consoleLogLevel = 0;
    loader = {
      timeout = lib.mkForce 0; # set to 10 in isoImage
      systemd-boot.enable = true;
    };
    initrd = {
      availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "usbhid" "sd_mod" "sdhci_pci" ];
      kernelModules = [ "dm-snapshot" ];
      luks.devices."crypt".device = "/dev/disk/by-partlabel/crypt";
      verbose = false;
    };
    kernelParams = [ "quiet" ]; #"udev.log_priority=3" ];
    extraModulePackages = [ ];
    #extraModprobeConfig = ''
    #  options snd-intel-dspcfg dsp_driver=3
    #'';
    # kernelPackages = pkgs.linuxKernel.packages.linux_5_17;
    kernelModules = with config.boot.kernelPackages; [ "kvm-intel" ];
  };


  fileSystems = {
    "/" = {
      device = "/dev/vg/root";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-label/boot";
      fsType = "vfat";
    };
  };
  swapDevices = [
    {
      device = "/dev/vg/swap";
    }
  ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
