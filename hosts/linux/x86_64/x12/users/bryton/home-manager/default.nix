{ pkgs, flake, ... }:
{
  home = {
    packages = with pkgs; [
      deploy-rs

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
      nextcloud-client
      newsflash
      sof-firmware
      youtube-dl
      bitwarden-cli
      siglo
      moserial

      nix-diff
    ] ++ (with flake.packages; [
      # effects
    ]);
  };
}
