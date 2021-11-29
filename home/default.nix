{ pkgs, ... }:
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
      gotify = {
        text = ''
          [gotify]
          url = "wss://notify.bryton.io"
          token = "${builtins.exec ["su" "-c" "echo -n '\"' && rbw get gotify --full | grep laptop | cut -f2 -d ' ' | tr -d '\\n' && echo -n '\"'" "bryton"]}"
          # auto_delete = true
        '';
        target = ".config/gotify-desktop/config.toml";
      };

      xonsh = {
        source = ./stage/.config/xonsh/rc.xsh;
        target = ".config/xonsh/rc.xsh";
      };
    };
  };
}
  