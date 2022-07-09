{ pkgs, flake, flakePkgs, ... }:
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
      # guitarix
      inkscape
      krita
      musescore
      prusa-slicer
      xournalpp
      element-desktop
      tdesktop
      gnome.gnome-boxes

      flakePkgs.moserial
      flakePkgs.siglo
      flakePkgs.effects
      wireshark

      talosctl
      nextcloud-client
      newsflash
      sof-firmware
      youtube-dl
      bitwarden-cli

      nix-diff
    ];
  };
}
