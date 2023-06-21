{ flake, pkgs, config, lib, modulesPath, ... }: {
  imports = [
    flake.inputs.hardware.nixosModules.raspberry-pi-4
    (modulesPath + "/installer/sd-card/sd-image-aarch64.nix")
  ];
  services.k8s.enable = true;

  # # boot.kernelPackages = lib.mkForce pkgs.linuxPackages_rpi4; # _6_1
  # boot.blacklistedKernelModules = [ "snd_pcsp" ];
  # boot.extraModprobeConfig = ''
  #   options snd slots=sndrpihifiberry
  # '';

  # users.users.${flake.lib.username}.extraGroups = [ "audio" ];
  # environment.systemPackages = with pkgs;[ alsa-utils dconf ];

  # hardware = {
  #   raspberry-pi."4".apply-overlays-dtmerge.enable = true;
  #   deviceTree = {
  #     enable = true;
  #     filter = "bcm2711-rpi-4-b.dtb";
  #     overlays = [{
  #       # https://www.hifiberry.com/docs/data-sheets/datasheet-amp2
  #       name = "hifiberry-dacplus";
  #       dtsText = with builtins; replaceStrings [ "bcm2835" ] [ "bcm2711" ] (readFile (fetchurl {
  #         url = "https://raw.githubusercontent.com/raspberrypi/linux/rpi-6.1.y/arch/arm/boot/dts/overlays/hifiberry-dacplus-overlay.dts";
  #         sha256 = "0sy57c8kkx04yzsy8r0p9n2fiv27c1vw46a668wjszir4y0147am";
  #       }));
  #     }];
  #   };
  # };

}
