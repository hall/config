{ pkgs, flake, ... }:
{
  vscode = import ./vscode.nix pkgs;
  firefox = import ./firefox pkgs;
  ssh = import ./ssh.nix { inherit pkgs flake; };
  git = import ./git.nix { inherit flake; };

  direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  gnome-terminal = {
    profile.default = { };
  };

  fzf = {
    enable = true;
  };

  gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
    };
  };
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
  };

}
 