{ pkgs, flakePkgs, ... }:
{
  home = {
    packages = with pkgs; [
      # pianobooster
      qjackctl
      #blender
      #faust
      #faustlive
      #gimp
      #siril
      ardour
      calibre
      guitarix
      inkscape
      krita
      musescore
      prusa-slicer
      xournalpp

      flakePkgs.moserial
    ];
  };
}
