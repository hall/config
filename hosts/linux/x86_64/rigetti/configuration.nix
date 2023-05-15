{ pkgs, flake, lib, ... }: {
  laptop.enable = true;

  services = {
    flatpak.enable = true;
    globalprotect.enable = true;
    # udev.packages = with pkgs; [ yubikey-personalization ];
  };
  environment.systemPackages = with pkgs; [
    globalprotect-openconnect
  ];

  # TODO: latest kernel doesn't boot
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_5_15;

  age.secrets.id_work = {
    file = ../../../../secrets/id_work.age;
    owner = flake.lib.username;
  };

  security.pam.services = {
    login.u2fAuth = true;
    sudo.u2fAuth = true;
  };

}
