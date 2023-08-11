{ pkgs, flake, ... }:
{
  vscode = import ./vscode.nix pkgs;

  firefox = import ./firefox pkgs;

  ssh = {
    enable = true;
    matchBlocks = {
      # not (yet?) managed by nix
      devices = {
        host = "switch ap1 ap2";
        user = "root";

        # TODO: ap2 needs these, dropbear is too old, I guess
        extraOptions = {
          PubkeyAcceptedKeyTypes = "+ssh-rsa";
          HostKeyAlgorithms = "+ssh-rsa";
        };
      };

      gitlab = {
        host = "gitlab.com";
        user = "git";
        identityFile = "/run/secrets/gitlab";
      };
      github = {
        host = "github.com";
        user = "git";
        identityFile = "/run/secrets/github";
      };

    };
  };

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
 