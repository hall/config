{ lib, config, pkgs, ... }:
{
  vscode = import ./vscode.nix pkgs;
  firefox = import ./firefox pkgs;
  ssh = import ./ssh.nix pkgs;
  git = import ./git.nix;
  # grm = import ./grm.nix;


  rbw = {
    enable = true;
    settings = {
      base_url = "https://bitwarden.bryton.io";
      email = "email@bryton.io";
      pinentry = "gnome3";
      # https://github.com/nix-community/home-manager/issues/2476
      device_id = "9c538100-b0e0-4d3e-b9ed-7b24f331a65a";
    };
  };

  # direnv = {};
  fzf = {
    enable = true;
  };
  gh = { enable = true; };
  # htop = { enable = true; };
  jq = { enable = true; };
  # obs-studio = { enable = true; };
  # font
  # keychain


  starship = {
    enable = true;
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
 