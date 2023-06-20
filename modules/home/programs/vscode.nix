{ pkgs, lib, ... }:
{
  enable = true;
  package = pkgs.vscodium;
  # TODO: breaks multi-profile installs
  # mutableExtensionsDir = false;
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

    "vs-kubernetes"."vs-kubernetes.kubeconfig" = "/run/secrets/kubeconfig";

    "window.autoDetectColorScheme" = true;
    "window.menuBarVisibility" = "toggle";

    # "workbench.experimental.sidePanel.enabled" = true;
    # "workbench.experimental.panel.alignment" = "left";

    "zenMode.centerLayout" = false;

  };
  extensions = (with pkgs.vscode-extensions; [
    # asciidoctor.asciidoctor-vscode
    eamodio.gitlens
    esbenp.prettier-vscode
    gruntfuggly.todo-tree
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
    ryu1kn.partial-diff
    # stkb.rewrap
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
    # {
    #   name = "foam-vscode";
    #   publisher = "foam";
    #   version = "0.21.0";
    #   sha256 = "sha256-X/vOqt6ijT+OHQNM5gTD8hapbi/PxpesnGy0vqVRQV0=";
    # }
    # {
    #   name = "vscode-paste-image";
    #   publisher = "mushan";
    #   version = "1.0.4";
    #   sha256 = "sha256-a6prHWZ8neNYJ+ZDE9ZvA79+5X0UlsFf8XSHYfOmd/I=";
    # }
    {
      # too old in nixpkgs
      name = "direnv";
      publisher = "mkhl";
      version = "0.10.1";
      sha256 = "sha256-Da9Anme6eoKLlkdYaeLFDXx0aQgrtepuUnw2jEPXCVU=";
    }
    # {
    #   # vscode-nix-ide dev uses this
    #   name = "esbuild-problem-matchers";
    #   publisher = "connor4312";
    #   version = "0.0.2";
    #   sha256 = "sha256-97Y+pJT/+MWOvyDwPqHoX3DnHhePaEvb0Mo+2bJvivE=";
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
