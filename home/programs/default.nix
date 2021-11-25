{ lib, config, pkgs, ... }:
{
  vscode = import ./vscode.nix pkgs;
  firefox = import ./firefox pkgs;
  ssh = import ./ssh.nix pkgs;
  git = import ./git.nix;


  rbw = {
    enable = true;
    settings = {
      base_url = "https://bitwarden.bryton.io";
      email = "email@bryton.io";
      pinentry = "gnome3";
    };
  };

  # direnv = {};
  fzf = {
    enable = true;
  };
  gh = { enable = true; };
  htop = { enable = true; };
  jq = { enable = true; };
  # obs-studio = { enable = true; };
  # font
  # keychain


  starship = {
    enable = true;
    package = pkgs.unstable.starship; # for xonsh support
    settings = {
      kubernetes = {
        disabled = false;
      };
    };
  };

  zoxide = {
    enable = true;
  };


  tmux = {
    enable = true;
    shortcut = "a";
    escapeTime = 0;
    keyMode = "vi";
  };

  neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    # plugins = [];
  };

}
 