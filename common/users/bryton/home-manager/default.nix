{ config, pkgs, flakePkgs, ... }:
{
  accounts = import ./accounts.nix;
  dconf = import ./dconf.nix;
  gtk = import ./gtk.nix pkgs;
  programs = import ./programs pkgs;
  services = import ./services.nix;
  systemd = import ./systemd.nix pkgs;

  home = {
    username = "bryton";
    homeDirectory = "/home/bryton";
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
      gotify = {
        text = ''
          [gotify]
          url = "wss://notify.bryton.io"
          token = "${builtins.exec ["su" "-c" "echo -n '\"' && rbw get gotify --full | grep laptop | cut -f2 -d ' ' | tr -d '\\n' && echo -n '\"'" "bryton"]}"
          # auto_delete = true
        '';
        target = ".config/gotify-desktop/config.toml";
      };
    };
  };
}
 