{ lib, flake, pkgs, config, ... }:
{
  imports = [
    flake.inputs.hardware.nixosModules.raspberry-pi-4
  ];
  # networking.firewall = {
  #   allowedTCPPorts = [ 8080 ];
  #   allowedUDPPorts = [ 8080 ];
  # };

  # environment.systemPackages = with pkgs; [
  #   sof-firmware
  # ];
  # hardware.raspberry-pi."4" = {
  #   audio.enable = true;
  # };

  swapDevices = [{ device = "/swapfile"; size = 1024; }];
  # sound.enable = lib.mkForce false;

  boot.kernelPackages = pkgs.linuxPackages_rpi4;
  # hardware.deviceTree = {
  #   enable = true;
  #   overlays = [ "${config.boot.kernelPackages.kernel}/dtbs/overlays/hifiberry-dacplus.dtbo" ];
  # };

  # force_eeprom_read=0
  # dtparam=audio=off
  # dtoverlay=vc4-fkms-v3d,audio=off
  boot.loader = {
    generic-extlinux-compatible.enable = lib.mkForce false;
    raspberryPi = {
      enable = true;
      version = 4;
      firmwareConfig = ''
        dtoverlay=hifiberry-dacplus
      '';
    };
  };

  # sound = {
  #   extraConfig = ''
  #     defaults.pcm.card 0
  #   '';
  # };

  systemd.services.snapclient = {
    wantedBy = [
      "pipewire.service"
      "multi-user.target" # enable on boot
    ];
    after = [
      "pipewire.service"
    ];
    serviceConfig = {
      ExecStart = "${pkgs.snapcast}/bin/snapclient -h office";
    };
  };

}
