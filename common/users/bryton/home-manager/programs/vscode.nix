{ pkgs, ... }:
{
  enable = true;
  package = pkgs.vscodium;
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
    "editor.fontFamily" = "Hack, monospace";
  };
  extensions = with pkgs.vscode-extensions; [
    # dendron (+ md shortcuts, paste image)
    # rest-client
    # jnoortheen.xonsh
    # remote containers
    alefragnani.project-manager
    arcticicestudio.nord-visual-studio-code
    arrterian.nix-env-selector
    asciidoctor.asciidoctor-vscode
    bbenoist.nix
    eamodio.gitlens
    editorconfig.editorconfig
    golang.go
    gruntfuggly.todo-tree
    hashicorp.terraform
    haskell.haskell
    james-yu.latex-workshop
    jnoortheen.nix-ide
    llvm-vs-code-extensions.vscode-clangd
    mikestead.dotenv
    ms-kubernetes-tools.vscode-kubernetes-tools
    ms-python.python
    ms-toolsai.jupyter
    # ms-vscode-remote.remote-ssh
    redhat.vscode-yaml
    streetsidesoftware.code-spell-checker
    vscodevim.vim
    yzhang.markdown-all-in-one
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
      command = "draw.editCurrentLineAsSVG";
    }
  ];
}
