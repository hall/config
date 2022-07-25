{ pkgs, lib, ... }:
{
  enable = true;
  package = pkgs.vscodium;
  mutableExtensionsDir = false;
  userSettings = {
    "draw.directory" = "assets";

    "editor.fontFamily" = "Hack, monospace";
    "editor.formatOnSave" = true;

    "explorer.confirmDelete" = false;
    "explorer.confirmDragAndDrop" = false;

    "git.confirmSync" = false;

    "jupyter.askForKernelRestart" = false;
    "jupyter.themeMatplotlibPlots" = true;
    "jupyter.widgetScriptSources" = [ "jsdelivr.com" "unpkg.com" ];

    "latex-workshop.view.pdf.invert" = 0.88;
    "latex-workshop.view.pdf.invertMode.enabled" = "auto";
    "latex-workshop.view.pdf.zoom" = "page-width";

    # https://wiki.dendron.so/notes/692fa114-f798-467f-a0b9-3cccc327aa6f/#remove-markdown-buttons-in-menu-bar
    "markdownShortcuts.icons.bold" = false;
    "markdownShortcuts.icons.bullets" = false;
    "markdownShortcuts.icons.italic" = false;
    "markdownShortcuts.icons.strikethrough" = false;

    "projectManager.git.baseFolders" = [ "~/src" ];
    "projectManager.git.maxDepthRecursion" = 5;

    "redhat.telemetry.enabled" = false;

    "rest-client.enableTelemetry" = false;
    "rest-client.previewResponseInUntitledDocument" = true;

    "revealjs.highlightTheme" = "nord";
    "revealjs.controls" = false;

    "todo-tree.regex.regex" = "(//|#|<!--|;|/\\*|^|^\\s*(-|\\d+.))\\s*($TAGS)";
    "todo-tree.highlights.customHighlight" = {
      "[ ]" = {
        "background" = "#ff000080";
      };
      "[x]" = {
        "background" = "#00ff0080";
      };
    };
    "todo-tree.general.tags" = [
      "BUG"
      "HACK"
      "FIXME"
      "TODO"
      "XXX"
      "[ ]"
      "[x]"
    ];

    "telemetry.telemetryLevel" = "off";

    "terminal.integrated.commandsToSkipShell" = [
      "-workbench.action.quickOpen" # ctrl-p
    ];
    "terminal.integrated.scrollback" = 5000;

    "update.mode" = "none";

    "window.autoDetectColorScheme" = true;
    "window.menuBarVisibility" = "toggle";

    "workbench.colorTheme" = "Nord";
    # "workbench.experimental.sidePanel.enabled" = true;
    "workbench.experimental.panel.alignment" = "left";

    "zenMode.centerLayout" = false;
  };
  extensions = (with pkgs.vscode-extensions; [
    alefragnani.project-manager
    arcticicestudio.nord-visual-studio-code
    # asciidoctor.asciidoctor-vscode
    eamodio.gitlens
    editorconfig.editorconfig
    esbenp.prettier-vscode
    gitlab.gitlab-workflow
    golang.go
    gruntfuggly.todo-tree
    # hashicorp.terraform
    # haskell.haskell
    humao.rest-client
    james-yu.latex-workshop
    jnoortheen.nix-ide
    jock.svg
    # llvm-vs-code-extensions.vscode-clangd
    # ms-kubernetes-tools.vscode-kubernetes-tools
    ms-toolsai.jupyter
    # ms-vscode-remote.remote-ssh
    # ms-vscode.cpptools
    redhat.vscode-yaml
    rust-lang.rust-analyzer
    ryu1kn.partial-diff
    # stkb.rewrap
    streetsidesoftware.code-spell-checker
    vscodevim.vim
    yzhang.markdown-all-in-one
  ] ++ (lib.optionals (pkgs.system != "aarch64-linux") [
    ms-python.python # unsupported
  ])) ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
    {
      name = "draw";
      publisher = "hall";
      version = "0.1.19";
      sha256 = "sha256-9yfqNyE0s13xNOeP/iAE1fUPvXdDiBrHJhQ1AnkrHE0=";
    }
    {
      name = "dendron";
      publisher = "dendron";
      version = "0.104.1";
      sha256 = "sha256-AmDRXaoTG0Fgn+uEBQeTW5m2ENDe2kX0ByM5hMYj6H0=";
    }
    {
      name = "dendron-paste-image";
      publisher = "dendron";
      version = "1.1.0";
      sha256 = "sha256-dhyTYsSVg3nXFdApTwRDC2ge5LYwVaX58uj5uJwoWqc=";
    }
    {
      name = "direnv";
      publisher = "mkhl";
      version = "0.6.1";
      sha256 = "sha256-5/Tqpn/7byl+z2ATflgKV1+rhdqj+XMEZNbGwDmGwLQ=";
    }
    {
      # to generate conf hosts task list
      name = "tasks-shell-input";
      publisher = "augustocdias";
      version = "1.7.0";
      sha256 = "sha256-s+kh3sFPmKTwyhumSeBnhFrdUV92CWvVjBMFUykipAE=";
    }
    {
      # for effects package
      name = "vscode-faust";
      publisher = "glen-anderson";
      version = "1.1.0";
      sha256 = "sha256-1aoyIN8qbMd2j3UnHUVe1YG9kmuCW/KXVkn5z7Z2SjU=";
    }
    {
      name = "vscode-reveal";
      publisher = "evilz";
      version = "4.3.3";
      sha256 = "sha256-KqvQi0DMfHppX96qKHIkO9zIueBdGGV+6dYkpFEzFBo=";
    }
    {
      name = "xonsh";
      publisher = "jnoortheen";
      version = "0.2.6";
      sha256 = "sha256-EhpIzYLn5XdvR5gAd129+KuyTcKFswXtO6WgVT8b+xA=";
    }
  ];
  keybindings = [
    {
      key = "meta+Escape"; # stylus tail button
      command = "draw.editCurrentLine";
    }

    # tmux
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
    # { TODO: fix
    #   key = "ctrl+a shift+'";
    #   command = "workbench.action.terminal.split";
    #   when = "terminalFocus && panelPosition != 'bottom'";
    # }
    {
      key = "ctrl+a shift+5";
      command = "workbench.action.terminal.split";
      when = "terminalFocus && panelPosition == 'bottom'";
    }

    # readline
    {
      key = "ctrl+n";
      command = "cursorLineStart";
      when = "terminalFocus";
    }
    {
      key = "ctrl+e";
      command = "cursorLineEnd";
      when = "terminalFocus";
    }
    {
      key = "ctrl+l";
      command = "workbench.action.terminal.clear";
      when = "terminalFocus";
    }

    # https://wiki.dendron.so/notes/692fa114-f798-467f-a0b9-3cccc327aa6f/#keep-track-of-tabs
    {
      key = "ctrl+t";
      command = "workbench.action.showAllEditors";
    }

    # disabled keys
    {
      key = "ctrl+l";
      command = "-extension.vim_navigateCtrlL";
    }
    {
      # markdown-all-in-one conflicts with dendron
      key = "ctrl+enter";
      command = "-markdown.extension.onCtrlEnterKey";
      when = "editorTextFocus && !editorReadonly && !suggestWidgetVisible && editorLangId == 'markdown'";
    }
  ];
}
