# NUC11PAHi7, 88:AE:DD:05:C9:46, F2 to enter bios
{ lib, pkgs, flake, ... }:
{
  imports = [ flake.inputs.hardware.nixosModules.intel-nuc-8i7beh ];

  # router = {
  #   enable = true;
  #   internal = "enp89s0";
  #   external = "enp0s2of0u4";
  # };

  kodi.enable = true;

  networking.interfaces.enp89s0.wakeOnLan.enable = true;

  # boot = {
  #   model=dell-headset-multi
  #   extraModprobeConfig = ''
  #     options snd slots=snd-hda-intel
  #     options snd-hda-intel index=0,1
  #   '';
  #   kernelModules = [ "snd-hda-intel" ];
  # };

  # sound.enable = true;

  # hardware = {
  #   pulseaudio.enable = lib.mkForce true;
  #   video.hidpi.enable = true;
  #   firmware = with pkgs; [
  #     firmwareLinuxNonfree
  #   ];
  #   opengl = {
  #     enable = true;
  #     extraPackages = with pkgs; [
  #       intel-media-driver
  #       vaapiIntel
  #       vaapiVdpau
  #       libvdpau-va-gl
  #     ];
  #   };
  # };

  # nixpkgs.config.packageOverrides = pkgs: {
  #   vaapiIntel = pkgs.vaapiIntel.override { 
  #     enableHybridCodec = true;
  #   };
  # };
}
