{ pkgs, flake, lib, ... }:
{
  laptop.enable = true;

  services.globalprotect.enable = true;
  environment.systemPackages = with pkgs; [
    globalprotect-openconnect
  ];

  age.secrets.id_work = {
    file = ../../../../secrets/id_work.age;
    owner = flake.username;
  };

}
