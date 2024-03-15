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
  ddcutil

  # tmux
  # tmuxPlugins.nord
  # tmuxPlugins.sensible
  # tmuxPlugins.vim-tmux-navigator
] ++ (with gnomeExtensions; [
  brightness-control-using-ddcutil
  gsconnect
  nasa-apod
  # improved-osk
  night-theme-switcher
  gesture-improvements
])
