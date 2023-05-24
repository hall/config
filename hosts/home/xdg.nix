{ pkgs, ... }:
let
  codeExec = "codium --touch-events %F";
in
{
  desktopEntries = {
    codium = {
      name = "VSCodium";
      exec = codeExec;
      icon = "code";
    };
    notes = {
      name = "Notes";
      exec = codeExec + " notes --profile notes";
      icon = ./notes.svg;
    };
  };
}
