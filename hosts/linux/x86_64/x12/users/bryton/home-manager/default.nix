{ pkgs, flake, ... }:
{
  home = {
    packages = with pkgs; [
      deploy-rs
      zotero

      # pianobooster
      qjackctl
      #blender
      #faust
      #faustlive
      #gimp
      #siril
      ardour
      calibre
      # guitarix
      inkscape
      krita
      musescore
      # prusa-slicer
      xournalpp
      element-desktop
      tdesktop
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

      nix-diff
    ] ++ (with flake.packages; [
      effects
      # itd
    ]);
  };
}
