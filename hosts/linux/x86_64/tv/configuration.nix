# NUC11PAHi7, 88:AE:DD:05:C9:46, F2 to enter bios
{ lib, pkgs, musnix, flake, ... }:
{
  imports = [ flake.inputs.hardware.nixosModules.intel-nuc-8i7beh ];
  boot.binfmt.emulatedSystems = [
    "aarch64-linux"
  ];

  # musnix.enable = true;
  # router = {
  #   enable = true;
  #   internal = "enp89s0";
  #   external = "enp0s2of0u4";
  # };

  # services.pipewire.config.pipewire-pulse = {
  #   "context.modules" = [
  #     { name = "libpipewire-module-allow-passthrough"; }
  #   ];
  # };

  # TODO: figure out a stable sound config
  services.pipewire.enable = lib.mkForce false;
  # hardware.pulseaudio.enable = lib.mkForce true;
  sound.enable = true;

  # boot.extraModprobeConfig = ''
  #   options snd-intel-dspcfg dsp_driver=1
  # '';

  kodi.enable = true;

  # networking.interfaces.enp89s0.wakeOnLan.enable = true;
  # environment.systemPackages = with pkgs; [
  #   sof-firmware
  # ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    #model=dell-headset-multi
    # extraModprobeConfig = ''
    #   options snd-hda-intel
    # '';
    kernelModules = [ "snd-hda-intel" ];
    # blacklistedKernelModules = [ "i915" ];
  };

  hardware = {
    video.hidpi.enable = true;
    # firmware = with pkgs; [
    #   firmwareLinuxNonfree
    # ];
    opengl = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
        vaapiIntel
        vaapiVdpau
        libvdpau-va-gl
      ];
    };
  };

  services.xserver.videoDrivers = [ "intel" ];

  nixpkgs.config = {
    #   allowUnfree = true;
    packageOverrides = pkgs: {
      vaapiIntel = pkgs.vaapiIntel.override {
        enableHybridCodec = true;
      };
    };
  };
}
