{ config, pkgs, flakePkgs, flake, ... }:
{
  accounts = import ./accounts.nix { inherit flake; };
  dconf = import ./dconf.nix;
  gtk = import ./gtk.nix pkgs;
  programs = import ./programs { inherit pkgs flake; };
  services = import ./services.nix;
  systemd = import ./systemd.nix pkgs;

  home = {
    username = flake.username;
    homeDirectory = "/home/${flake.username}";
    stateVersion = "21.05";
    packages = import ./packages.nix { inherit config pkgs flakePkgs; };
    sessionVariables = {
      CALIBRE_USE_DARK_PALETTE = "1";
      MOZ_USE_XINPUT2 = "1";
      EDITOR = "nvim";
    };
    file = {
      config = {
        recursive = true;
        source = ../stage/.config/xonsh;
        target = ".config/xonsh";
      };
      bin = {
        recursive = true;
        source = ../stage/bin;
        target = "bin/";
      };
      kube = {
        recursive = true;
        source = ../stage/.kube;
        target = ".kube/";
      };
    };
  };
}
 