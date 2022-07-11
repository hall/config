{ config, pkgs, flake, lib, ... }:
{
  programs = {
    vscode = {
      userSettings = {
        "editor.folding" = false;
        "editor.minimap.enabled" = false;
        "editor.glyphMargin" = false;
        "git.decorations.enabled" = false;
        "editor.scrollbar.vertical" = "hidden";
        # "workbench.editor.splitInGroupLayout" = "vertical";
        "workbench.editor.openSideBySideDirection" = "down";
      };
      extensions = pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          name = "toggle-zen-mode";
          publisher = "fudd";
          version = "1.1.2";
          sha256 = "sha256-ug1LVun0StMwpWfbtWmkpIVyvTr/ukKwxSEHG+1dFXI=";
        }
      ];
    };
  };
}
 
