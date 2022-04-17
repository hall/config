{ lib, pkgs, ... }:
{
  users.users.bryton = {
    isNormalUser = true;
    shell = pkgs.xonsh;
    extraGroups = [
      "audio"
      "dialout"
      "docker"
      "i2c"
      "input"
      "wheel"
      #"wireshark"
    ];
  };
}