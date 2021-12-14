{ pkgs, ... }:
with pkgs; [
  # talosctl

  nixpkgs-fmt
  python-language-server
  niv
  newsflash
  wl-clipboard
  syncthing-gtk
  gotify-desktop
  nextcloud-client
  barrier
  libreoffice
  # chromium
  # networkmanager-openconnect
  # openconnect
  # globalprotect-openconnect
  shellcheck

  sof-firmware
  opensnitch-ui


  # appimage-run
  # calibre
  # direnv
  # dnsutils
  # hunspell
  # hunspellDicts.en_US-large
  # #google-drive-ocamlfuse
  dbeaver
  # #file
  # #scrcpy
  # barrier
  # #go-task
  # #hadolint
  # #goss
  # #qemu-utils
  # #libsForQt5.full
  # unstable.lighttpd
  # gnupg
  # iperf
  youtube-dl
  # #istioctl
  # pre-commit
  # #shellcheck
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
  # wireshark

  # math / science
  #jupyter
  #sagemath
  #stellarium

  # cli
  pciutils
  # #velero
  # #azure-cli
  # #terraform
  # #pulumi-bin
  bash-completion
  bitwarden-cli
  fzf
  # google-cloud-sdk
  awscli2
  # inotify-tools
  # lsof
  # #pdsh
  # #packer
  # #gitlab-runner
  # plan9port
  ripgrep
  # #s3cmd
  # telnet
  # gparted
  # unzip
  # yq

  # comms
  #ferdi
  discord
  slack
  tdesktop
  # zoom-us
  element-desktop

  # # gnome
  gnome.dconf-editor
  gnome.gnome-todo
  # gnome.gnome-boxes
  # gnome3.gnome-tweaks
  gnome.gnome-remote-desktop
  gnomeExtensions.bluetooth-quick-connect
  gnomeExtensions.brightness-control-using-ddcutil
  gnomeExtensions.gsconnect
  # gnomeExtensions.material-shell
  gnomeExtensions.nasa-apod
  gnomeExtensions.syncthing-icon
  gnomeExtensions.night-light-slider
  gnomeExtensions.unite
  gnomeExtensions.wireguard-indicator
  ddcutil

  # # dev
  # #gcc
  # #gh
  # #gnumake
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
  # docker
  # #docker-compose
  # helmfile
  # k3s
  # krew
  # #kube3d TODO: too old?
  kubectl
  # kubernetes-helm
  # #kubetail
  # kustomize
  kubie # TODO: merge xonsh support
  # krew
  # unstable.skaffold

  # tmux
  tmuxPlugins.nord
  tmuxPlugins.sensible
  tmuxPlugins.vim-tmux-navigator

  # design
  ardour
  #avldrums-lv2
  #freecad
  #blender
  #gimp
  #pianobooster
  #imagemagick
  #faust
  #faustlive
  #guitarix
  #inkscape
  #openscad
  prusa-slicer
  #surge
  #siril
  #flameshot
  xournalpp
  krita
]
