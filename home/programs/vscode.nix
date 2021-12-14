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
    "todo-tree.highlights.customHighlight" = {
      "[ ]" = {
        "background" = "#ff000080";
      };
      "[x]" = {
        "background" = "#00ff0080";
      };
    };

    "terminal.integrated.commandsToSkipShell" = [
      "-workbench.action.quickOpen" # ctrl-p
    ];
    "projectManager.git.baseFolders" = [ "~/src" ];
  };
  extensions = with pkgs.vscode-extensions; [
    # dendron
    # rest-client
    # jnoortheen.xonsh
    alefragnani.project-manager
    arcticicestudio.nord-visual-studio-code
    arrterian.nix-env-selector
    asciidoctor.asciidoctor-vscode
    bbenoist.nix
    eamodio.gitlens
    editorconfig.editorconfig
    formulahendry.code-runner
    golang.go
    gruntfuggly.todo-tree
    hashicorp.terraform
    haskell.haskell
    james-yu.latex-workshop
    jnoortheen.nix-ide
    mikestead.dotenv
    ms-kubernetes-tools.vscode-kubernetes-tools
    ms-python.python
    redhat.vscode-yaml
    stkb.rewrap
    streetsidesoftware.code-spell-checker
    vscodevim.vim
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
    # {
    #   key = "ctrl+n";
    #   command = "cursorHome";
    #   when = "terminalFocus";
    # }
    # {
    #   key = "ctrl+e";
    #   command = "cursorEnd";
    #   when = "terminalFocus";
    # }
    {
      key = "ctrl+l";
      command = "workbench.action.terminal.clear";
      when = "terminalFocus";
    }
  ];
}
