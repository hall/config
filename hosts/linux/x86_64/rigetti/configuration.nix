{ pkgs, flake, lib, ... }:
{
  laptop.enable = true;

  services = {
    flatpak.enable = true;
    globalprotect.enable = true;
    # udev.packages = with pkgs; [ yubikey-personalization ];
  };
  environment.systemPackages = with pkgs; [
    globalprotect-openconnect
  ];

  age.secrets.id_work = {
    file = ../../../../secrets/id_work.age;
    owner = flake.username;
  };

}
