{ lib, ... }: {
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
  };

  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";

  boot = {
    initrd.availableKernelModules = [ "xhci_pci" ];
    initrd.services.lvm.enable = false;
    kernelParams = [ "rootwait" ];
  };

  services.fstrim = {
    enable = true;
    interval = "weekly";
  };

  # https://github.com/NixOS/nixpkgs/issues/126755
  nixpkgs.overlays = [
    (final: super: {
      makeModulesClosure = x:
        super.makeModulesClosure (x // { allowMissing = true; });
    })
  ];
}
