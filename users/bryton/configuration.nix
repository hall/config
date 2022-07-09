{ lib, pkgs, flake, ... }:
{
  users.users.${flake.username} = {
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

      "feedbackd"
      "video"
      "networkmanager"
    ];
  };
}
