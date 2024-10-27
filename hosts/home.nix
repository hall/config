{ config, flake, pkgs, specialArgs, ... }: {
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
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
      # file.logseq".source = flake.nixosConfigurations.${}.lib.file.mkOutOfStoreSymlink "/home/${flake.lib.username}/notes/data";
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
        direnv = {
          enable = true;
          nix-direnv.enable = true;
        };
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
          # initExtra = ''
          #   set -o vi
          # '';
        };

        zoxide.enable = true;

        yazi = {
          enable = true;
          enableBashIntegration = true;
        };

        neovim = {
          enable = true;
          viAlias = true;
          vimAlias = true;
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
