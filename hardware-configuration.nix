# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/0324d9e7-5d54-4df7-8ef9-3ca0d1b9bc9c";
      fsType = "ext4";
    };

  boot.initrd.luks.devices."crypted".device = "/dev/disk/by-uuid/ae5e19f1-4867-4208-8e85-31864e2ebe24";

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/5A71-6B86";
      fsType = "vfat";
    };

  fileSystems."/home/bryton" =
    { device = "/dev/disk/by-uuid/9eedfa85-17d1-49c7-bf69-92464cb3ed8d";
      fsType = "ext4";
    };

  boot.initrd.luks.devices."luks-6a437026-df40-452f-b1d2-caa230a8a746".device = "/dev/disk/by-uuid/6a437026-df40-452f-b1d2-caa230a8a746";

  swapDevices =
    [ { device = "/dev/disk/by-uuid/13194f0e-4628-4ecf-b0d6-a504567ec212"; }
    ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  # high-resolution display
  hardware.video.hidpi.enable = lib.mkDefault true;
}
