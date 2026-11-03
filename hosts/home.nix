{ config, flake, pkgs, specialArgs, ... }: {
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    # backupFileExtension = "backup";
    extraSpecialArgs = specialArgs;
    users.${flake.lib.username} = {
      home = {
        username = flake.lib.username;
        homeDirectory = "/home/${flake.lib.username}";
        stateVersion = config.system.stateVersion;
        packages = with pkgs; [
          dnsutils
          inetutils
          pciutils
          xxh
        ];
      };
      xdg.configFile."xxh/config.xxhc".text = builtins.toJSON ({
        hosts.".*" = {
          "+s" = "bash";
          "+I" = "xxh-shell-bash";
        };
      });
      programs = {
        readline = {
          enable = true;
          extraConfig = ''
            set editing-mode vi
            set show-mode-in-prompt on
            $if term=linux
            	set vi-ins-mode-string \1\e[?0c\2
            	set vi-cmd-mode-string \1\e[?8c\2
            $else
            	set vi-ins-mode-string \1\e[6 q\2
            	set vi-cmd-mode-string \1\e[2 q\2
            $endif
          '';
        };
        starship.enable = true;
        ssh = {
          enable = true;
          enableDefaultConfig = false;
          settings = {
            "gitlab.com".User = "git";
            "github.com".User = "git";
          };
        };

        git = {
          enable = true;
          settings = {
            user = {
              name = flake.lib.name;
              email = flake.lib.email;
            };
            init.defaultBranch = "main";
            pull.rebase = false;
            commit.verbose = true;
            push.autoSetupRemote = true;
          };
          # difftastic.enable = true;
          lfs.enable = true;
        };

        fzf.enable = true;
        ripgrep.enable = true;

        gh = {
          enable = true;
          settings.git_protocol = "ssh";
        };
        htop = { enable = true; };
        jq = { enable = true; };

        bash = {
          enable = true;
          shellAliases = {
            cd = "z";
            awsp = ''export AWS_PROFILE=$(sed -n "s/\[profile \(.*\)\]/\1/gp" ~/.aws/config | ${pkgs.fzf}/bin/fzf)'';
          };
          bashrcExtra = ''
            eval "$(devenv hook bash)"

            shopt -s histappend
            # save all lines of a multiline command together
            shopt -s cmdhist
            # embed newlines, not semicolons, in multiline commands
            shopt -s lithist
            # split multiline commands when flushed to history file
            HISTTIMEFORMAT='%F %T '
          '';
        };

        zoxide.enable = true;

        yazi = {
          enable = true;
          enableBashIntegration = true;
          shellWrapperName = "y";
        };

        neovim = {
          enable = true;
          viAlias = true;
          vimAlias = true;
          withRuby = false;
          withPython3 = false;
        };
        tmux = {
          enable = true;
          shortcut = "a";
          escapeTime = 0;
          keyMode = "vi";
        };

      };
    };
  };
}
