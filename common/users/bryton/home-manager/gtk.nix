{ lib, config, pkgs, ... }:
{
  enable = true;
  theme = {
    name = "Adwaita-dark";
  };
  font = {
    package = pkgs.hack-font;
    name = "Hack Regular";
  };
  gtk3 = {
    extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
  };
}
