{ config, lib, pkgs, musnix, flake, flakePkgs, ... }:
{
  nixpkgs = {
    overlays = [
      # enable raspberrypi support in libcec
      (self: super: { libcec = super.libcec.override { inherit (self) libraspberrypi; }; })
      # https://github.com/NixOS/nixos-hardware/issues/360
      (final: super: {
        makeModulesClosure = x:
          super.makeModulesClosure (x // { allowMissing = true; });
      })
    ];
  };

  hardware.raspberry-pi."4" = {
    # enable gpu (e.g., fullscreen)
    fkms-3d.enable = true;
    audio.enable = true;
    poe-hat.enable = true;
  };

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
          # widevine (the drm provider) does not provide aarch64 binaries
          # package = (pkgs.pkgsCross.armv7l-hf-multiplatform.kodi-wayland.withPackages (kodiPkgs: with kodiPkgs; [
          package = (pkgs.kodi-wayland.withPackages (kodiPkgs: with kodiPkgs; [
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
