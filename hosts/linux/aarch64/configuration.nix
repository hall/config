{ flake, modulesPath, ... }:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
  };

  swapDevices = [ ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";

  boot = {
    loader.grub.enable = false;
    initrd.availableKernelModules = [ "xhci_pci" "usb_storage" ];
  };

  services = {
    openssh = {
      enable = true;
      # passwordAuthentication = false;
      # permitRootLogin = "no";
      # allowSFTP = false;
    };
  };


  # https://github.com/NixOS/nixpkgs/issues/126755
  nixpkgs.overlays = [
    (final: super: {
      makeModulesClosure = x:
        super.makeModulesClosure (x // { allowMissing = true; });
    })
  ];
}
