{ lib, config, pkgs, ... }:
{
  enable = true;
  font = {
    package = pkgs.hack-font;
    name = "Hack Regular";
  };
}
