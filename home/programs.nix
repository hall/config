{ lib, config, pkgs, ... }:
{
  git = {
    enable = true;
    userName = "Bryton Hall";
    userEmail = "email@bryton.io";
    extraConfig = {
      init = {
        defaultBranch = "main";
      };
      url = {
        "git@gitlab.com:" = {
          insteadOf = "https://gitlab.com/";
        };
      };
    };
  };

  firefox = {
    enable = true;
    profiles = {
      default = {
        id = 0;
        name = "default";
        settings = {
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          "browser.tabs.drawInTitlebar" = false;
          "browser.search.defaultenginename" = "duckduckgo";
          "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
          "signon.rememberSignons" = false;
          "devtools.theme" = "dark";
          "svg.context-properties.content.enabled" = true;
          "projectManager.git.baseFolders" = "~/src";
        };
        userChrome = builtins.readFile ../userChrome.css;
        userContent = builtins.readFile ../userContent.css;
      };
    };
    extensions = with pkgs.nur.repos.rycee.firefox-addons; [
      anchors-reveal
      auto-tab-discard
      #buster
      #bypass-paywalls
      darkreader
      i-dont-care-about-cookies
      # gsconnect # TODO: doesn't exist
      # ipfs-companion
      # sidebery # TODO: doesn't exist
      refined-github
      floccus
      link-cleaner
      multi-account-containers
      temporary-containers
      ublock-origin
      bitwarden
      vim-vixen
      https-everywhere
    ];
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

  vscode = {
    enable = true;
    package = pkgs.vscodium;
    userSettings = {
      "update.mode" = "none";
      "files.associations" = {
        "**.yaml.gotmpl" = "helm";
        "**.yaml.jinja" = "helm";
        "helmfile.yaml" = "helm";
      };
      "explorer.confirmDelete" = false;
      "explorer.confirmDragAndDrop" = false;
      "editor.formatOnSave" = true;
      "git.confirmSync" = false;
      "todo-tree.regex.regex" = "(//|#|<!--|;|/\\*|^|^\\s*(-|\\d+.))\\s*($TAGS)";
      "todo-tree.general.tags" = [
        "BUG"
        "HACK"
        "FIXME"
        "TODO"
        "XXX"
        "[ ]"
        "[x]"
      ];
      "terminal.integrated.commandsToSkipShell" = [
        "-workbench.action.quickOpen" # ctrl-p
      ];
    };
    extensions = with pkgs.vscode-extensions; [
      # dendron
      ms-python.python
      eamodio.gitlens
      # rest-client
      # xonsh
      bbenoist.Nix
      jnoortheen.nix-ide
      formulahendry.code-runner
      haskell.haskell
      # golang.Go
      gruntfuggly.todo-tree
      james-yu.latex-workshop
      ms-kubernetes-tools.vscode-kubernetes-tools
      redhat.vscode-yaml
      vscodevim.vim
      hashicorp.terraform
    ];
    keybindings = [
      {
        key = "ctrl+a c";
        command = "workbench.action.terminal.newInActiveWorkspace";
      }
      {
        key = "ctrl+a o";
        command = "workbench.action.terminal.focus";
      }
      {
        key = "ctrl+a o";
        command = "workbench.action.focusActiveEditorGroup";
        when = "terminalFocus";
      }
      {
        key = "ctrl+a z";
        command = "workbench.action.toggleMaximizedPanel";
        when = "terminalFocus";
      }
      {
        key = "ctrl+a n";
        command = "workbench.action.terminal.focusNext";
        when = "terminalFocus";
      }
      {
        key = "ctrl+a p";
        command = "workbench.action.terminal.focusPrevious";
        when = "terminalFocus";
      }
      {
        key = "ctrl+a shift+'";
        command = "workbench.action.terminal.split";
        when = "terminalFocus && panelPosition != 'bottom'";
      }
      {
        key = "ctrl+a shift+5";
        command = "workbench.action.terminal.split";
        when = "terminalFocus && panelPosition == 'bottom'";
      }
      {
        key = "ctrl+a a";
        command = "cursorHome";
        when = "terminalFocus";
      }
      {
        key = "ctrl+e";
        command = "cursorEnd";
        when = "terminalFocus";
      }
      {
        key = "ctrl+l";
        command = "workbench.action.terminal.clear";
        when = "terminalFocus";
      }
    ];
  };
}
