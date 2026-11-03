args: {
  vscode = import ./vscode.nix args;
  firefox = import ./firefox args;

  obsidian = {
    enable = true;
    vaults.notes.target = "notes";
  };

  foot = {
    enable = true;
    settings.mouse.hide-when-typing = "yes";
  };

}
