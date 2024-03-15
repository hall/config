{ pkgs, lib, ... }: {
  enable = true;
  # TODO: breaks multi-profile installs
  mutableExtensionsDir = false;
  userSettings = {
    "3dpreview.hideControlsOnStart" = true;
    "3dpreview.showMesh" = true;

    "diffEditor.ignoreTrimWhitespace" = false;

    "draw.directory" = "assets";

    "editor.fontFamily" = "Hack, monospace";
    "editor.formatOnSave" = true;

    "autoReveal" = false;
    "explorer.confirmDelete" = false;
    "explorer.confirmDragAndDrop" = false;

    "git.confirmSync" = false;
    "git.pruneOnFetch" = true;

    "jupyter.askForKernelRestart" = false;
    "jupyter.themeMatplotlibPlots" = true;
    "jupyter.widgetScriptSources" = [ "jsdelivr.com" "unpkg.com" ];

    "latex-workshop.view.pdf.invert" = 0.88;
    "latex-workshop.view.pdf.invertMode.enabled" = "auto";
    "latex-workshop.view.pdf.zoom" = "page-width";

    "[markdown]" = {
      "editor.defaultFormatter" = "yzhang.markdown-all-in-one";
    };

    "nix.enableLanguageServer" = true;
    "nix.serverPath" = "${pkgs.nil}/bin/nil";
    "nix.serverSettings" = {
      nil.formatting.command = [ "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt" ];
    };

    "redhat.telemetry.enabled" = false;

    "rest-client.enableTelemetry" = false;
    "rest-client.previewResponseInUntitledDocument" = true;

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

    # "workbench.experimental.sidePanel.enabled" = true;
    # "workbench.experimental.panel.alignment" = "left";

    "zenMode.centerLayout" = false;

  };
  extensions = (with pkgs.vscode-extensions; [
    # james-yu.latex-workshop
    ms-vscode-remote.remote-containers
    ms-azuretools.vscode-docker

    eamodio.gitlens
    esbenp.prettier-vscode
    github.copilot
    github.copilot-chat
    gruntfuggly.todo-tree
    humao.rest-client
    jnoortheen.nix-ide
    jock.svg
    mkhl.direnv
    ms-toolsai.jupyter
    ryu1kn.partial-diff
    streetsidesoftware.code-spell-checker
    vscodevim.vim
    yzhang.markdown-all-in-one
  ] ++ (lib.optionals (pkgs.system != "aarch64-linux") [
    ms-python.python # unsupported
  ])) ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
    # TODO: move to dedicated profile
    # {
    #   name = "draw";
    #   publisher = "hall";
    #   version = "0.1.21";
    #   sha256 = "sha256-pOZwuvUJWaEQn1zdHHTNvzK8KUS46Np5wuR7GDFGtis=";
    # }
    {
      # to generate conf hosts task list
      name = "tasks-shell-input";
      publisher = "augustocdias";
      version = "1.7.0";
      sha256 = "sha256-s+kh3sFPmKTwyhumSeBnhFrdUV92CWvVjBMFUykipAE=";
    }
    # {
    #   # for effects package
    #   name = "vscode-faust";
    #   publisher = "glen-anderson";
    #   version = "1.1.0";
    #   sha256 = "sha256-1aoyIN8qbMd2j3UnHUVe1YG9kmuCW/KXVkn5z7Z2SjU=";
    # }
    # {
    #   name = "vscode-reveal";
    #   publisher = "evilz";
    #   version = "4.3.3";
    #   sha256 = "sha256-KqvQi0DMfHppX96qKHIkO9zIueBdGGV+6dYkpFEzFBo=";
    # }
    {
      name = "QML";
      publisher = "bbenoist";
      version = "1.0.0";
      sha256 = "sha256-tphnVlD5LA6Au+WDrLZkAxnMJeTCd3UTyTN1Jelditk=";
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

    # conflicts
    {
      key = "ctrl+k";
      command = "-extension.vim_ctrl+k";
    }

    # don't leave notebook cell with esc
    {
      key = "escape";
      command = "-notebook.cell.quitEdit";
    }
  ];
}
