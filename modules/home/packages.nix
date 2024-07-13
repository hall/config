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
  dconf-editor
  gnome.gnome-sound-recorder
  # gnome.gnome-boxes
  # gnome3.gnome-tweaks
  # gnome.gnome-remote-desktop
  ddcutil

  gtop
] ++ (with gnomeExtensions; [
  astra-monitor
  bluetooth-battery-meter
  brightness-control-using-ddcutil
  gsconnect
  nasa-apod
  # improved-osk
  night-theme-switcher
  just-perfection
])
