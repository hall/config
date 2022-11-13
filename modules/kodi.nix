{ config, lib, pkgs, flake, ... }:
let
  name = "kodi";
  cfg = config.${name};

  kodi = (pkgs.kodi-wayland.withPackages (k: with k; [
    youtube
    controller-topology-project
    iagl
    # invidious
    # jellyfin
    joystick
    libretro
    netflix
    steam-library
    # steam-launcher
  ]));

in
{
  options.${name} = {
    enable = lib.mkEnableOption "media center";
  };

  config = lib.mkIf cfg.enable {

    programs = {
      steam.enable = true;
      # xwayland.enable = true;
    };

    hardware = {
      xpadneo.enable = true;
      bluetooth = {
        enable = true;
        disabledPlugins = [ "sap" ];
      };
    };

    environment = {
      systemPackages = with pkgs;[
        libcamera
        libva
        sof-firmware
        libcec
        libva-utils
      ];
    };

    networking.firewall = {
      allowedTCPPorts = [
        8080 # web ui
        9090 # json-rpc
      ];
      allowedUDPPorts = [
        9777 # event server
      ];
    };

    # allow binding kodi to port 80
    # security.wrappers.kodi = {
    #   owner = flake.username;
    #   group = "root";
    #   capabilities = "cap_net_bind_service=+eip";
    #   source = "${kodi.outPath}/lib/kodi/kodi.bin";
    # };

    # x11:
    # - steam not fullscreen
    # - shutdown hangs
    # wayland:
    # - kodi fails on display on
    #
    # both: pipewire problems :/
    services = {
      dbus.enable = true;
      upower.enable = true;

      cage = {
        enable = true;
        user = flake.username;
        program = "${kodi}/bin/kodi-standalone";
      };
    };

    # xdg.portal = {
    #   enable = true;
    #   wlr.enable = true;
    #   # gtk portal needed to make gtk apps happy
    #   extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    #   # gtkUsePortal = true;
    # };

    users.users.${flake.username}.extraGroups = [
      "audio"
      "sound"
      "video"
      # "lp"
      "dialout" # cec
    ];

  };
}
