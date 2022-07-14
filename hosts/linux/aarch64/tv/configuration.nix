{ config, lib, pkgs, musnix, ... }:
{
  users.users.kodi = {
    isNormalUser = true;
    extraGroups = [ "video" ];
  };

  networking.firewall = {
    allowedTCPPorts = [ 8080 ];
    allowedUDPPorts = [ 8080 ];
  };

  environment.systemPackages = with pkgs; [
    libcec
  ];

  services = {
    udev.extraRules = ''
      # allow access to raspi cec device for video group (and optionally register it as a systemd device, used below)
      SUBSYSTEM=="vchiq", GROUP="video", MODE="0660", TAG+="systemd", ENV{SYSTEMD_ALIAS}="/dev/vchiq"
    '';
    xserver = {
      enable = true;
      desktopManager = {
        kodi = {
          enable = true;
          # widevine is only available on 32bit arm
          package = (pkgs.pkgsCross.armv7l-hf-multiplatform.kodi-wayland.withPackages (kodiPkgs: with kodiPkgs; [
            inputstream-adaptive
            # jellyfin
            # iagl
            # youtube
            # netflix
            # libretro
            ## zephyr
          ]));
        };
      };
      displayManager = {
        autoLogin = {
          enable = true;
          user = "kodi";
        };
      };
    };
  };
}
