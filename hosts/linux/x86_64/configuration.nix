{ pkgs, ... }: {

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
    kernelPackages = pkgs.linuxPackages_latest;
  };

  # powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = true;

  systemd.services.tailscaled.after = [ "NetworkManager-wait-online.service" ];
}
