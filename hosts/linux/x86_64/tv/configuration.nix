# NUC11PAHi7, 88:AE:DD:05:C9:46, F2 to enter bios
{ lib, pkgs, musnix, flake, ... }:
{
  imports = [ flake.inputs.hardware.nixosModules.intel-nuc-8i7beh ];
  boot.binfmt.emulatedSystems = [
    "aarch64-linux"
  ];

  kodi.enable = true;
  monitor.enable = true;
  registry.enable = true;
  hyperion.enable = true;

  # TODO: figure out a stable sound config
  services.pipewire.enable = lib.mkForce false;
  sound.enable = true;

  # networking.interfaces.enp89s0.wakeOnLan.enable = true;

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

  nixpkgs.config = {
    #   allowUnfree = true;
    packageOverrides = pkgs: {
      vaapiIntel = pkgs.vaapiIntel.override {
        enableHybridCodec = true;
      };
    };
  };
}
