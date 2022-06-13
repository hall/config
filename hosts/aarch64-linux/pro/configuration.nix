{ config, lib, pkgs, ... }:
let
  username = "bryton";
in
{
  imports = [ ./hardware.nix ];

  boot.loader.grub.enable = false;
  # numeric password is currently required to unlock a session
  # TODO change me!
  users.users = {
    ${username} = {
      isNormalUser = true;
      group = "users";
      password = "1234";
    };
    root.password = "1234";
    # geoclue.extraGroups = [ "networkmanager" ];
  };

  hardware = {
    sensor.iio.enable = true;
  };


  services = {
    fwupd.enable = true;

    xserver.desktopManager.phosh = {
      enable = true;
      user = username;
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
    chatty
    megapixels
    gnome.gnome-terminal
  ];

  programs.calls.enable = true;

}
