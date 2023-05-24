{ config, pkgs, flake, lib, ... }:
with pkgs; [
  nixpkgs-fmt
  wl-clipboard
  dnsutils
  inetutils

  # cli
  pciutils
  bash-completion
  fzf
  ripgrep
  yq
  gh

  # gnome
  gnome.dconf-editor
  # gnome.gnome-boxes
  # gnome3.gnome-tweaks
  # gnome.gnome-remote-desktop
  gnomeExtensions.bluetooth-quick-connect
  gnomeExtensions.brightness-control-using-ddcutil
  gnomeExtensions.gsconnect
  gnomeExtensions.nasa-apod
  gnomeExtensions.syncthing-icon
  gnomeExtensions.unite
  # gnomeExtensions.improved-osk
  gnomeExtensions.night-theme-switcher
  gnomeExtensions.gesture-improvements
  ddcutil

  rnix-lsp

  # tmux
  # tmuxPlugins.nord
  # tmuxPlugins.sensible
  # tmuxPlugins.vim-tmux-navigator
]
