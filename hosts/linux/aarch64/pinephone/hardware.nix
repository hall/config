{ lib, ... }: {
  fileSystems = {
    "/" = lib.mkForce {
      device = "/dev/disk/by-label/NIXOS_SYSTEM";
      fsType = "ext4";
    };
    "/home" = {
      device = "/dev/disk/by-label/home";
      fsType = "ext4";
    };
  };
}
