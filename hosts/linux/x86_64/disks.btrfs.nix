{ config, ... }: {
  disko.devices = {
    disk.main = {
      type = "disk";
      device = "/dev/nvme0n1";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "512M";
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
                # dd if=/dev/random of=/dev/sda bs=2048 count=1
                keyFile = "/dev/sda";
                keyFileSize = 2048;
                fallbackToPassword = true;
                allowDiscards = true;
              };
              # Use a postCreateHook to add the passphrase from a file
              # https://github.com/nix-community/disko/issues/415
              postCreateHook = with config.disko.devices.disk.main.content.partitions.luks; ''
                cryptsetup luksAddKey \
                  --key-file ${content.settings.keyFile} \
                  --keyfile-size ${toString content.settings.keyFileSize} \
                  /dev/disk/by-partlabel/${label} ${config.age.secrets.luks.path}
              '';
              content = {
                type = "btrfs";
                extraArgs = [ "-L" "nixos" "-f" ];
                mountOptions = [ "compress=zstd" "noatime" ];
                subvolumes = {
                  "/root".mountpoint = "/";
                  "/nix".mountpoint = "/nix";
                  "/persist".mountpoint = "/persist";
                  "/swap" = {
                    mountpoint = "/swap";
                    swap.swapfile.size = "16G";
                  };
                };
              };
            };
          };
        };
      };
    };
  };
  fileSystems = {
    "/persist".neededForBoot = true;
    # "/var/log".neededForBoot = true;
  };
}
