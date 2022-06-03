{ config, pkgs, flakePkgs, ... }:
with pkgs; [
  nixpkgs-fmt
  # python-language-server
  niv
  wl-clipboard
  libreoffice
  shellcheck
  dbeaver
  dnsutils
  wireshark

  # appimage-run
  # direnv
  # hunspell
  # hunspellDicts.en_US-large
  # #file
  # #go-task
  # #hadolint
  # #goss
  # gnupg
  # iperf
  # koreader
  # moreutils
  # #zotero
  # #transmission-gtk
  # #usbutils
  # #binutils
  # #anki
  # jellyfin-media-player
  # #pprof
  # zip

  # math / science
  #jupyter
  # sage
  #stellarium

  # cli
  pciutils
  # #velero
  bash-completion
  fzf
  # inotify-tools
  # lsof
  # #pdsh
  # plan9port
  ripgrep
  # telnet
  # gparted
  # unzip
  yq

  # comms
  slack

  # # gnome
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
  # gnomeExtensions.wireguard-indicator
  gnomeExtensions.night-theme-switcher
  ddcutil

  # # dev
  # #gcc
  gh
  # #gnumake
  ## c
  clang-tools
  # ## go
  # #air
  # #delve
  # #go
  # #go-outline
  # #gocode
  # #gocode-gomod
  # #godef
  # #golint
  # #gopkgs
  # #goreleaser
  # ## python
  # micromamba
  # #poetry
  # #conda
  # #R
  # #pyenv
  # ## node
  # #yarn
  # nodejs
  # ## rust
  # #rustup
  # ## java
  # #openjdk
  # #maven

  # containers
  # lens
  flakePkgs.openlens
  docker-buildx
  kubectl
  kubie

  # tmux
  tmuxPlugins.nord
  tmuxPlugins.sensible
  tmuxPlugins.vim-tmux-navigator
]
