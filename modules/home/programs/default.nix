{ pkgs, flake, lib, config, ... }: {
  vscode = import ./vscode.nix pkgs;
  firefox = import ./firefox pkgs;

  ssh = {
    enable = true;
    matchBlocks = {
      gitlab = {
        host = "gitlab.com";
        user = "git";
      };
      github = {
        host = "github.com";
        user = "git";
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

  swaylock = {
    enable = true;
    settings.no-unlock-indicator = true;
  };

  tofi = {
    enable = true;
    settings = {
      anchor = "top";
      width = "100%";
      height = 30; # config.programs.waybar.settings.default.height;
      horizontal = true;
      # font-size = 14;
      prompt-text = " ";
      outline-width = 0;
      border-width = 0;
      min-input-width = 120;
      result-spacing = 15;
      # padding-top = 0;
      # padding-bottom = 0;
      padding-left = 0;
      padding-right = 0;
    };
  };

  waybar = {
    enable = true;
    settings.default = {
      height = 20;
      output = [ "eDP-1" ];
      # layer = "top";
      modules-left = [ "sway/workspaces" "sway/mode" ];
      modules-center = [ "sway/window" ];
      modules-right = [ "battery" "wireplumber" "clock" ];
      "sway/window" = {
        max-length = 50;
      };
      # cpu = {
      #   format = "{usage}% ";
      #   tooltip = false;
      # };
      # memory = {
      #   format = "{used:0.1f}G ";
      # };
      battery = {
        format = "{icon}";
        format-icons = [ "" "" "" "" "" ];
      };
      clock = {
        format-alt = "{:%a, %d. %b  %H:%M}";
      };
      wireplumber = {
        format = "{icon}";
        format-muted = "";
        on-click = "helvum";
        format-icons = [ "" "" "" ];
      };
    };
    style = ''
      * {
        font-size: 12px;
        min-height: 0;
      }
    '';
  };


  direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  fzf.enable = true;
  ripgrep.enable = true;

  gh = {
    enable = true;
    settings.git_protocol = "ssh";
  };
  htop = { enable = true; };
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

  yazi = {
    enable = true;
    enableBashIntegration = true;
  };

  k9s.enable = true;

  foot = {
    enable = true;
    settings.mouse.hide-when-typing = "yes";
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
 