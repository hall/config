{ config, pkgs, flake, ... }: {
  vscode = import ./vscode.nix pkgs;
  firefox = import ./firefox pkgs;

  ssh.enable = true;

  git = {
    enable = true;
    userName = flake.lib.name;
    userEmail = flake.lib.email;
    # difftastic.enable = true;
    lfs.enable = true;
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = false;
      commit.verbose = true;
    };
  };

  direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  gnome-terminal.profile.default = { };

  fzf.enable = true;

  gh = {
    enable = true;
    settings.git_protocol = "ssh";
  };
  # htop = { enable = true; };
  jq = { enable = true; };
  # obs-studio = { enable = true; };
  # font
  # keychain

  bash = {
    enable = true;
    shellAliases = {
      cd = "z";
      awsp = ''export AWS_PROFILE=$(sed -n "s/\[profile \(.*\)\]/\1/gp" ~/.aws/config | ${pkgs.fzf}/bin/fzf)'';
    };
    # initExtra = ''
    #   set -o vi
    # '';
  };

  readline = {
    enable = true;
    extraConfig = ''
      set keymap vi
    '';
  };

  starship.enable = true;

  zoxide.enable = true;

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
 