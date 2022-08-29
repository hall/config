# NUC11PAHi7, 88:AE:DD:05:C9:46, F2 to enter bios
{ lib, pkgs, flake, ... }:
let
  kodi = (pkgs.kodi-wayland.passthru.withPackages (k: with k; [
    # youtube
    # controller-topology-project
    iagl
    invidious
    jellyfin
    joystick
    libretro
    netflix
    steam-library
    # steam-launcher
  ]));
in
{
  imports = [flake.inputs.hardware.nixosModules.intel-nuc-8i7beh ];
  boot = {
    # kernelPackages = pkgs.linuxPackages_latest;
    # model=dell-headset-multi
    # extraModprobeConfig = ''
    #   options snd slots=snd-hda-intel
    #   options snd-hda-intel index=0,1
    # '';
    kernelModules = [ "snd-hda-intel" ];
  };
  networking = {
    firewall = {
      allowedTCPPorts = [
        8080 # web ui (old)
        # 80 # web ui
        9090 # json-rpc
      ];
      allowedUDPPorts = [
        9777 # event server
      ];
    };
    interfaces.enp89s0.wakeOnLan.enable = true;
  };

  # allow binding kodi to port 80
  # security.wrappers.kodi = {
  #   owner = flake.username;
  #   group = "root";
  #   capabilities = "cap_net_bind_service=+eip";
  #   source = "${kodi.outPath}/lib/kodi/kodi.bin";
  # };

  programs.steam.enable = true;

  hardware = {
    video.hidpi.enable = true;
    firmware = with pkgs; [
      firmwareLinuxNonfree
    ];
    bluetooth = {
      enable = true;
      disabledPlugins = [ "sap" ];
    };
    xpadneo.enable = true;
    enableRedistributableFirmware = true;
    # opengl = {
    #   enable = true;
    #   extraPackages = with pkgs; [
    #     intel-media-driver
    #     vaapiVdpau
    #     libvdpau-va-gl
    #   ];
    # };
  };

  # nixpkgs.config.packageOverrides = pkgs: {
  #   vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  # };

  environment = {
    systemPackages = with pkgs;[
      libcamera
      libva
      sof-firmware
      libcec
    ];
  };

  users.users.${flake.username}.extraGroups = [
    "audio"
    "sound"
    "video"
    "lp"
    "dialout" # cec
  ];

  services = {
    upower.enable = true;
    cage = {
      enable = true;
      user = flake.username;
      program = "${kodi}/bin/kodi-standalone";
    };
  };
}
