{
  pkgs,
  lib,
  config,
  ...
}:
{
  enable = true;
  mutableExtensionsDir = false;
  profiles.default = {
    userSettings = {
      "3dpreview.hideControlsOnStart" = true;
      "3dpreview.showMesh" = true;

      "diffEditor.ignoreTrimWhitespace" = false;

      "draw.directory" = "assets";

      # stylix sets just the monospace font; append font-awesome as a fallback
      # so icon glyphs (e.g. in waybar config) render instead of boxes
      "editor.fontFamily" =
        lib.mkForce "'${config.stylix.fonts.monospace.name}', 'Font Awesome 7 Free', 'Font Awesome 7 Brands'";
      "editor.formatOnSave" = true;

      # extensions come from nix; marketplace updates install unpatched binaries
      "extensions.autoUpdate" = false;
      "extensions.autoCheckUpdates" = false;

      "explorer.autoReveal" = false;
      "explorer.confirmDelete" = false;
      "explorer.confirmDragAndDrop" = false;

      "git.blame.editorDecoration.enabled" = true;
      "git.blame.statusBarItem.enabled" = true;
      "git.confirmSync" = false;
      "git.pruneOnFetch" = true;
      "git.autoRefresh" = true;

      "jupyter.askForKernelRestart" = false;
      "jupyter.themeMatplotlibPlots" = true;
      "jupyter.widgetScriptSources" = [
        "jsdelivr.com"
        "unpkg.com"
      ];

      "latex-workshop.view.pdf.invert" = 0.88;
      "latex-workshop.view.pdf.invertMode.enabled" = "auto";
      "latex-workshop.view.pdf.zoom" = "page-width";

      "[markdown]" = {
        "editor.defaultFormatter" = "yzhang.markdown-all-in-one";
      };

      "nix.enableLanguageServer" = true;
      "nix.serverPath" = "${pkgs.nixd}/bin/nixd";
      "nix.serverSettings" = {
        nixd.formatting.command = [ "${pkgs.nixfmt}/bin/nixfmt" ];
      };

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
      "terminal.integrated.showExitAlert" = false;

      "update.mode" = "none";

      "vim.useCtrlKeys" = true;
      "vim.normalModeKeyBindingsNonRecursive" = [
        {
          "before" = [ "u" ];
          "commands" = [ "undo" ];
        }
        {
          "before" = [ "<C-r>" ];
          "commands" = [ "redo" ];
        }
      ];

      "window.menuBarVisibility" = "toggle";
      "window.titleBarStyle" = "native";

      "workbench.layoutControl.enabled" = false;

      "zenMode.centerLayout" = false;

    };
    extensions = (
      with pkgs.vscode-marketplace;
      [
        # james-yu.latex-workshop
        # ms-vscode-remote.remote-containers
        #esbenp.prettier-vscode
        # github.vscode-github-actions
        #gruntfuggly.todo-tree
        #humao.rest-client

        #bbenoist.qml
        # to generate conf hosts task list
        # replace?
        augustocdias.tasks-shell-input

        # glen-anderson.vscode-faust
        # evilz.vscode-reveal

      ]
      ++ (with pkgs.vscode-extensions; [
        # nixpkgs autoPatchelfs the bundled native binary
        anthropic.claude-code
        datakurre.devenv
        jnoortheen.nix-ide
        jock.svg
        ms-azuretools.vscode-docker
        ms-toolsai.jupyter
        naumovs.color-highlight
        ryu1kn.partial-diff
        streetsidesoftware.code-spell-checker
        vscodevim.vim
        yzhang.markdown-all-in-one

      ])
      ++ (lib.optionals (pkgs.stdenv.hostPlatform.system != "aarch64-linux") [
        ms-python.python # unsupported
      ])
    );
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
  };
}
