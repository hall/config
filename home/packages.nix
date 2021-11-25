{ pkgs, ... }:
with pkgs; [
  # talosctl
  nixpkgs-fmt
  python-language-server
  niv


  # appimage-run
  # calibre
  # direnv
  # dnsutils
  # esphome
  # hunspell
  # hunspellDicts.en_US-large
  # #google-drive-ocamlfuse
  # #dbeaver
  # #file
  # #libguestfs-with-appliance
  # gnome.gdm
  # #scrcpy
  # #spice
  # barrier
  # #go-task
  # #hadolint
  # #goss
  # #qemu-utils
  # #libsForQt5.full
  # freetype
  # #podofo
  # unstable.lighttpd
  # gnupg
  # iperf
  # youtube-dl
  # #istioctl
  # libreoffice
  # ncurses
  # #fdupes
  # nextcloud-client
  # openconnect
  # pinentry_gnome
  # #pkg-config
  # newsflash
  # #postgresql
  # pre-commit
  # #shellcheck
  # koreader
  syncthing-gtk
  # moreutils
  # #zotero
  # unstable.starship
  # #transmission-gtk
  # #usbutils
  # rpi-imager
  # #binutils
  # open-sans
  # #flutter
  # #wget
  # #anki
  # jellyfin-media-player
  # #pprof
  # zip
  # #mitmproxy
  # wireshark
  # wl-clipboard
  # xorg.xprop

  # # math / science
  # #jupyter
  # #sagemath
  # #stellarium

  # # cli
  # #velero
  # #azure-cli
  # #fio
  # #terraform
  # #pulumi-bin
  # bash-completion
  # bitwarden-cli
  # fzf
  # google-cloud-sdk
  # awscli2
  # inotify-tools
  # jq
  # #jsonnet
  # #sops
  # lsof
  # #pdsh
  # #packer
  # #gitlab-runner
  # plan9port
  # ripgrep
  # #s3cmd
  # #speedtest-cli
  # telnet
  # gparted
  # unzip
  # yq
  # zoxide

  # # comms
  # #ferdi
  discord
  # slack
  tdesktop
  # zoom-us
  # #element-desktop

  # # gnome
  gnome.dconf-editor
  # gnome.gnome-todo
  # gnome.gnome-boxes
  # gnome3.gnome-tweaks
  gnome.gnome-remote-desktop
  gnomeExtensions.bluetooth-quick-connect
  unstable.gnomeExtensions.brightness-control-using-ddcutil
  gnomeExtensions.gsconnect
  # gnomeExtensions.material-shell
  gnomeExtensions.nasa-apod
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

  # # containers
  unstable.lens
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
  # #kubie # TODO: merge xonsh support
  # krew
  # unstable.skaffold

  # # tmux
  # tmuxPlugins.nord
  # tmuxPlugins.sensible
  # tmuxPlugins.vim-tmux-navigator

  # # design
  # ardour
  # #avldrums-lv2
  # #freecad
  # #blender
  # #gimp
  # #pianobooster
  # imagemagick
  # #faust
  # #faustlive
  # guitarix
  # inkscape
  # #openscad
  # prusa-slicer
  # #surge
  # #siril
  # #flameshot
  # xournalpp

]

