{ pkgs, lib, ... }:
{
  enable = true;
  package = pkgs.vscodium;
  # mutableExtensionsDir = false;
  userSettings = {
    "update.mode" = "none";
    "files.associations" = {
      "**.yaml.gotmpl" = "helm";
      "**.yaml.jinja" = "helm";
      "helmfile.yaml" = "helm";
      "**.pyx" = "python";
    };
    "explorer.confirmDelete" = false;
    "explorer.confirmDragAndDrop" = false;
    "editor.formatOnSave" = true;
    "draw.directory" = "assets";
    "git.confirmSync" = false;
    "jupyter.widgetScriptSources" = [ "jsdelivr.com" "unpkg.com" ];
    "jupyter.themeMatplotlibPlots" = true;
    "jupyter.askForKernelRestart" = false;
    "window.autoDetectColorScheme" = true;
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
    "latex-workshop.view.pdf.invertMode.enabled" = "auto";
    "latex-workshop.view.pdf.invert" = 0.88;
    "latex-workshop.view.pdf.zoom" = "page-width";
    "todo-tree.highlights.customHighlight" = {
      "[ ]" = {
        "background" = "#ff000080";
      };
      "[x]" = {
        "background" = "#00ff0080";
      };
    };

    "terminal.integrated.scrollback" = 5000;
    "terminal.integrated.commandsToSkipShell" = [
      "-workbench.action.quickOpen" # ctrl-p
    ];
    "projectManager.git.baseFolders" = [ "~/src" ];
    "projectManager.git.maxDepthRecursion" = 5;

    # https://wiki.dendron.so/notes/692fa114-f798-467f-a0b9-3cccc327aa6f/#remove-markdown-buttons-in-menu-bar
    "markdownShortcuts.icons.bold" = false;
    "markdownShortcuts.icons.italic" = false;
    "markdownShortcuts.icons.strikethrough" = false;
    "markdownShortcuts.icons.bullets" = false;
    # "workbench.experimental.sidePanel.enabled" = true;
    "workbench.experimental.panel.alignment" = "left";
    "redhat.telemetry.enabled" = false;
    "window.menuBarVisibility" = "toggle";
    "telemetry.telemetryLevel" = "off";
    "rest-client.enableTelemetry" = true;
    "rest-client.previewResponseInUntitledDocument" = true;
    "editor.fontFamily" = "Hack, monospace";
    "zenMode.centerLayout" = false;
  };
  extensions = (with pkgs.vscode-extensions; [
    # remote containers
    alefragnani.project-manager
    arcticicestudio.nord-visual-studio-code
    asciidoctor.asciidoctor-vscode
    eamodio.gitlens
    editorconfig.editorconfig
    golang.go
    gruntfuggly.todo-tree
    hashicorp.terraform
    haskell.haskell
    james-yu.latex-workshop
    jnoortheen.nix-ide
    # llvm-vs-code-extensions.vscode-clangd
    mikestead.dotenv
    ms-kubernetes-tools.vscode-kubernetes-tools
    ms-toolsai.jupyter
    # ms-vscode-remote.remote-ssh
    redhat.vscode-yaml
    streetsidesoftware.code-spell-checker
    vscodevim.vim
    yzhang.markdown-all-in-one
    # ms-vscode.cpptools
  ] ++ (lib.optionals (pkgs.system != "aarch64-linux") [
    ms-python.python # unsupported
  ])) ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
    {
      name = "dendron";
      publisher = "dendron";
      version = "0.99.0";
      sha256 = "sha256-UpizlcpNNx81+0MSCwO42srRPI2EhZDpa0ly3rdARzE=";
    }
    {
      name = "xonsh";
      publisher = "jnoortheen";
      version = "0.2.6";
      sha256 = "sha256-EhpIzYLn5XdvR5gAd129+KuyTcKFswXtO6WgVT8b+xA=";
    }
    {
      name = "tasks-shell-input";
      publisher = "augustocdias";
      version = "1.7.0";
      sha256 = "sha256-s+kh3sFPmKTwyhumSeBnhFrdUV92CWvVjBMFUykipAE=";
    }
    {
      name = "rest-client";
      publisher = "humao";
      version = "0.24.6";
      sha256 = "sha256-g1RSkRnKamuaegmNX6MnDLfKL0SQThr2XQgRsN+p16Q=";
    }
    {
      name = "vscode-faust";
      publisher = "glen-anderson";
      version = "1.1.0";
      sha256 = "sha256-1aoyIN8qbMd2j3UnHUVe1YG9kmuCW/KXVkn5z7Z2SjU=";
    }
    {
      name = "cpptools";
      publisher = "ms-vscode";
      version = "1.11.0";
      sha256 = "sha256-JGgX2fB07OWZDeTs4lwl90aJOweUlylRy2iAubfouG0=";
    }
    {
      name = "cmake-tools";
      publisher = "ms-vscode";
      version = "1.12.1";
      sha256 = "sha256-I47Um4YV6AglC2fs5NrLZaqxmCw/J+rZox6I/V4t2tY=";
    }
    {
      name = "direnv";
      publisher = "mkhl";
      version = "0.6.1";
      sha256 = "sha256-5/Tqpn/7byl+z2ATflgKV1+rhdqj+XMEZNbGwDmGwLQ=";
    }
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
    {
      key = "ctrl+l";
      command = "-extension.vim_navigateCtrlL";
    }
    {
      key = "meta+Escape"; # stylus tail button
      command = "draw.editCurrentLine";
    }
  ];
}
