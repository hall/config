{ pkgs, ... }:
{
  accounts = import ./accounts.nix;
  dconf = import ./dconf.nix;
  gtk = import ./gtk.nix pkgs;
  programs = import ./programs pkgs;
  services = import ./services.nix;

  home = {
    username = "bryton";
    homeDirectory = "/home/bryton";
    stateVersion = "21.05";
    packages = import ./packages.nix pkgs;
    sessionVariables = {
      CALIBRE_USE_DARK_PALETTE = "1";
      EDITOR = "nvim";
    };
    file = {
      # config = {
      #   recursive = true;
      #   source = ./stage/.config;
      #   target = ".config";
      # };
      xonsh = {
        source = ./stage/.config/xonsh/rc.xsh;
        target = ".config/xonsh/rc.xsh";
      };
    };
  };
}
  