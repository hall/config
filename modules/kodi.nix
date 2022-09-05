{ config, lib, pkgs, flake, ... }:
let
  name = "kodi";
  cfg = config.${name};

  kodi = (pkgs.kodi.passthru.withPackages (k: with k; [
    youtube
    # controller-topology-project
    iagl
    # invidious
    jellyfin
    joystick
    # libretro
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

    # TODO: figure out a stable sound config
    services.pipewire.enable = lib.mkForce false;
    hardware.pulseaudio.enable = lib.mkForce true;
    sound.enable = true;

    programs.steam.enable = true;

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
    # - no sound
    # - kodi fails to start randomly
    #
    # both: pipewire problems :/
    services = {
      upower.enable = true;

      # cage = {
      #   enable = true;
      #   user = flake.username;
      #   program = "${kodi}/bin/kodi-standalone";
      # };

      xserver = {
        enable = true;
        desktopManager.kodi = {
          enable = true;
          package = kodi;
        };
        displayManager.autoLogin = {
          enable = true;
          user = flake.username;
        };
      };
    };

    users.users.${flake.username}.extraGroups = [
      "audio"
      "sound"
      "video"
      # "lp"
      "dialout" # cec
    ];

  };
}
