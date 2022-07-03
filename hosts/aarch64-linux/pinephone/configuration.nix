{ config, lib, pkgs, musnix, flake, ... }:
{
  imports = [
    ./hardware.nix
    (import "${flake.inputs.mobile}/lib/configuration.nix" { device = "pine64-pinephonepro"; })
    ../../../modules/wifi.nix
  ];

  musnix.enable = true;

  boot.loader.grub.enable = false;
  # users.users.geoclue.extraGroups = [ "networkmanager" ];

  services = {
    fwupd.enable = true;
    flatpak = {
      enable = true;
      # bitwarden
      # dialect
    };

    xserver.desktopManager.phosh = {
      enable = true;
      user = flake.username;
      group = "users";
    };

    openssh = {
      enable = true;
      # passwordAuthentication = false;
      # permitRootLogin = "no";
      # allowSFTP = false;
    };

    # geoclue.enable = true;

  };

  environment.systemPackages = with pkgs; [
    # element-desktop
    # tdesktop

    # talosctl
    # nextcloud-client
    # newsflash

    chatty
    megapixels
    epiphany
    guitarix
    newsflash
    giara

    gnome.gnome-terminal
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
    waydroid
    #telegram
  ];

  programs.calls.enable = true;

}
