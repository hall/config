{ config, lib, pkgs, musnix, flake, flakePkgs, ... }:
{
  imports = [
    ./hardware.nix
    (import "${flake.inputs.mobile}/lib/configuration.nix" { device = "pine64-pinephonepro"; })
    ../../../modules/syncthing.nix
    ../../../modules/wifi.nix
    (import ../../../modules/effects.nix { inherit flakePkgs pkgs flake; kernel = "controlC3"; })
  ];

  musnix.enable = true;

  boot.loader.grub.enable = false;
  # users.users.geoclue.extraGroups = [ "networkmanager" ];

  services = {
    fwupd.enable = true;
    flatpak = {
      enable = true;
      # dialect
    };

    xserver.desktopManager.phosh = {
      enable = true;
      user = flake.username;
      group = "users";
      phocConfig = {
        xwayland = "immediate";
      };
    };

    geoclue2 = {
      enable = true;
      appConfig."gammastep" = {
        isAllowed = true;
        isSystem = true;
      };
    };

    redshift = {
      enable = true;
      package = pkgs.gammastep;
      executable = "/bin/gammastep";
    };
  };

  sound.enable = true;
  location.provider = "geoclue2";

  environment = {
    variables = {
      WEBKIT_FORCE_SANDBOX = "0"; # workaround for epiphany
  };

    systemPackages = with pkgs; [
      # purple-matrix
      # purple-slack
      # telegram-purple
      pinentry-curses
      pinentry-gnome

      lingot
      fmit
      # cozy
      sooperlooper

    # element-desktop
      protonmail-bridge

    # talosctl
    # nextcloud-client
    # newsflash

    chatty
    megapixels
    epiphany
    newsflash
    giara
      nheko

    gnome.gnome-terminal
      # gnome-connections
    gnome.gnome-calendar
    gnome.gnome-contacts
    gnome.gnome-calculator
    gnome.gnome-clocks
    #gnome.gnome-documents # broken
    gnome.gnome-maps
    gnome.gnome-music
    gnome-photos
    gnome.gnome-weather
    gnome.gnome-system-monitor
    gnome.gnome-sound-recorder

    gnome.gnome-todo
    gnome.gnome-notes
    gnome.gnome-books
    gnome.gnome-screenshot
    gnome.gnome-dictionary
      gnome.gnome-disk-utility
    gnome-podcasts

    gnome.geary # email
    gnome.totem # videos
    gnome.gedit # editor
    gnome.nautilus # files
    gnome.eog # images
    drawing
    fragments
    banking
    tootle
      # waydroid
      tdesktop
      pure-maps
      # siglo
      # ardour

      usbutils
      libusb

      flakePkgs.effects
  ];
  };

  programs.calls.enable = true;

}
