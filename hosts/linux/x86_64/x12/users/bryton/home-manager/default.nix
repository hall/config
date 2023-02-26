{ pkgs, flake, ... }:
{
  home = {
    packages = with pkgs; [
      deploy-rs
      zotero

      # pianobooster
      qjackctl
      #faust
      #faustlive
      #gimp
      #siril
      ardour
      calibre
      guitarix
      inkscape
      krita
      blender
      musescore
      prusa-slicer
      xournalpp
      element-desktop
      gnome.gnome-boxes

      wireshark

      talosctl
      newsflash
      sof-firmware
      gnome.gnome-todo
      youtube-dl
      bitwarden-cli
      siglo
      moserial
      cachix

      nix-diff
    ] ++ (with flake.packages; [
      effects
    ]);
  };
}
