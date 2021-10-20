{ lib, config, pkgs, ... }:

let
  home-manager = builtins.fetchGit {
    url = "https://github.com/rycee/home-manager.git";
    rev = "35a24648d155843a4d162de98c17b1afd5db51e4";
    ref = "release-21.05";
  };

  py-packages = python-packages: with python-packages; [
    pandas
    pip
    pylint
    black
    #poetry
    grpcio
    setuptools
    tabulate
    pyyaml
    kubernetes
  ];
  python-packages = pkgs.python3.withPackages py-packages;

in
{
  #nix = {
  #  package = pkgs.nixUnstable;
  #  extraOptions = ''
  #    experimental-features = nix-command flakes
  #  '';
  # };

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      (import "${home-manager}/nixos")
      <musnix>
    ];

  musnix.enable = true;
  hardware.pulseaudio.enable = false;


  # Use the systemd-boot EFI boot loader.
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  time.timeZone = "America/New_York";

  networking = {
    hostName = "thinkpad";
    interfaces = {
      enp0s31f6.useDHCP = true;
      wlp0s20f3.useDHCP = true;
    };
    firewall = {
      enable = true;
      allowedTCPPorts = [
        1716 # gsconnect
        ];
    };
    wireguard = {
      enable = true;
    };
    networkmanager = {
      dispatcherScripts = [{
        type = "basic";
	source = pkgs.writeText "upHook" ''
	  export PATH=$PATH:/run/current-system/sw/bin
          if [[ "$(nmcli -t -f NAME connection show --active)" == "hall" ]]; then
            setting=false
          fi
          su -l bryton -c "dbus-launch dconf write /org/gnome/desktop/screensaver/lock-enabled ''${setting:-true}"
	'';
      }];
    };
  };

  console = {
    useXkbConfig = true;
  };

  services = {
    xserver = {
      enable = true; 
      displayManager = {
        gdm.enable = true;
	      autoLogin = {
	        enable = true;
	        user = "bryton";
	      };
      };
      desktopManager.gnome.enable = true;
      layout = "us";
      xkbVariant = "dvorak";
    };

    interception-tools = {
      enable = true;
      plugins = with pkgs.interception-tools-plugins; [
        caps2esc
      ];
    };

    fprintd = {
      enable = true;
    };

    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
      jack.enable = true;
    };
  };

  virtualisation = {
    docker = {
      enable = true;
      enableOnBoot = false;
    };
  };

  users.users.bryton = {
    isNormalUser = true;
    shell = pkgs.xonsh;
    extraGroups = [
      "audio"
      "adbusers"
      "dialout"
      "docker"
      "input"
      "wheel"
      "wireshark"
    ];
  };

  security = {
    sudo.extraRules = [
      {
        users = [ "bryton" ];
        commands = [ { command = "ALL"; options = [ "NOPASSWD" ]; } ];
      }
    ];
    pam = {
      services = {
        login = {
          fprintAuth = true;
        };
      };
    };
    rtkit.enable = true;
  };

  environment = {
    variables = {
      EDITOR = "nvim";
    };
    sessionVariables = {
      CALIBRE_USE_DARK_PALETTE = "1";
    };
    systemPackages = with pkgs; [
      curl
      gnomeExtensions.gsconnect
    ];
  };

  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05";


  programs = {
    dconf.enable = true;
    wireshark.enable = true;
    adb.enable = true;
    gnupg.agent = {
      enable = true;
      pinentryFlavor = "gnome3";
    };
    xonsh = {
      enable = true;
      config = builtins.readFile ./xonshrc;
    };

  };

  nixpkgs.config = {
    allowBroken = true; # syncthing
    packageOverrides = pkgs: {
      nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
        inherit pkgs;
      };
    };
    allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "vscode-extension-ms-toolsai-jupyter"
    "zoom"
    "slack"
      "discord"
    "teams"
  ];
  };

  home-manager.users.bryton = {
    home.packages = with pkgs; [
      #fprintd-tod
      #libfprint-tod
      appimage-run
      calibre
      direnv
      dnsutils
      esphome
      etcher
      file
      libguestfs-with-appliance
      scrcpy
      qemu-utils
      gnupg
      iperf
      istioctl
      libreoffice
      ncurses
      nextcloud-client
      openconnect
      openssl
      pinentry_gnome
      pkg-config
      postgresql
      pre-commit
      shellcheck
      transmission-gtk
      usbutils
      rpi-imager
      binutils
      open-sans
      wget
      wireshark
      wl-clipboard
      xonsh
      xorg.xprop

      # math / science
      jupyter
      sagemath
      stellarium

      # cli
      velero
      azure-cli
      #terraform
      #pulumi-bin
      bash-completion
      bitwarden-cli
      fzf
      google-cloud-sdk
      inotify-tools
      jq
      jsonnet
      sops
      lsof
      pdsh
      packer
      gitlab-runner
      ripgrep
      s3cmd
      speedtest-cli
      telnet
      gparted
      unzip
      yq
      zoxide
      
      # comms
      ferdi
      slack
      tdesktop
      teams
      zoom-us
      element-desktop

      # gnome
      gnome.dconf-editor
      gnome.gnome-todo
      gnome.gnome-boxes
      gnome3.gnome-tweaks
      gnomeExtensions.bluetooth-quick-connect
      gnomeExtensions.nasa-apod
      gnomeExtensions.night-light-slider
      gnomeExtensions.unite
      gnomeExtensions.brightness-control-using-ddcutil
      gnomeExtensions.wireguard-indicator
      ddcutil

      # dev
      gcc
      gh
      gnumake
      ## go
      air
      go
      go-outline
      gocode
      gocode-gomod
      godef
      golint
      gopkgs
      goreleaser
      ## python
      poetry
      python-packages
      ## node
      yarn
      nodejs
      ## rust
      cargo

      # containers
      lens
      docker
      docker-compose
      helmfile
      k3s
      krew
      #kube3d TODO: too old?
      kubectl
      kubernetes-helm
      kubetail
      kubie
      #skaffold TODO: too old

      # tmux
      tmuxPlugins.nord
      tmuxPlugins.sensible
      tmuxPlugins.vim-tmux-navigator

      # design
      ardour
      freecad
      blender
      gimp
      guitarix
      inkscape
      openscad
      prusa-slicer
      siril
      flameshot
      xournalpp
    ];

    accounts = {
      email = {
        accounts = {
          personal = {
            address = "email@bryton.io";
            realName = "Bryton Hall";
            primary = true;
            userName = "email@bryton.io";
            passwordCommand = "bw get password protonmail";
            imap = {
              host = "imap.bryton.io";
              port = 1143;
              tls = {
                enable = true;
                useStartTls = true;
               };
             };
             smtp = {
              host = "smtp.bryton.io";
               port = 1120;
               tls = {
                enable = true;
                 useStartTls = true;
              };
             };
          };
        };
      };
    };

    gtk = {
      enable = true;
      theme = {
        name = "Adwaita-dark";
      };
      font = {
        package = pkgs.hack-font;
        name = "Hack Regular";
      };
      gtk3 = {
        extraConfig = {
          gtk-application-prefer-dark-theme = true;
        };
      };
    };

    dconf = {
      settings = {
        "org/gnome/settings-daemon/plugins/color" = {
          night-light-enabled = true;
        };
        "org/gnome/settings-daemon/plugins/power" = {
          sleep-inactive-ac-timeout = 2400;
        };
        "org/gnome/mutter" = {
          workspaces-only-on-primary = false;
        };
        "org/gnome/desktop/interface" = {
          enable-hot-corners = false;
        };
        "org/gnome/desktop/screensaver" = {
          lock-delay = 3600;
        };
      	"org/gnome/desktop/wm/preferences" = {
      	  focus-mode = "sloppy";
      	};
      };
    };

    services = {
      nextcloud-client = {
        enable = true;
        startInBackground = true;
      };
    };

    programs = {
      git = {
        enable = true;
        userName  = "Bryton Hall";
        userEmail = "email@bryton.io";
       	extraConfig = {
       	  init = {
       	    defaultBranch = "main";
       	  };
       	  url = {
       	    "git@gitlab.com:" = {
       	      insteadOf = "https://gitlab.com/";
            };
       	  };
       	};
      };

      firefox = {
        enable = true;
        profiles = {
          default = {
            id = 0;
            name = "default";
            settings = {
              "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
              "browser.tabs.drawInTitlebar" = false;
              "browser.search.defaultenginename" = "duckduckgo";
              "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
              "signon.rememberSignons" = false;
              "devtools.theme" = "dark";
              "svg.context-properties.content.enabled" = true;
            };
            userChrome = builtins.readFile ./userChrome.css;
            userContent = builtins.readFile ./userContent.css;
          };
        };
        extensions = with pkgs.nur.repos.rycee.firefox-addons; [
          anchors-reveal
          auto-tab-discard
          #buster
          #bypass-paywalls
          darkreader
          i-dont-care-about-cookies
          # gsconnect
          # ipfs-companion
          refined-github
          floccus
          link-cleaner
          multi-account-containers
          temporary-containers
          ublock-origin
          bitwarden
          tree-style-tab
          vim-vixen
          https-everywhere
        ];
      };

      tmux = {
        enable = true;
        shortcut = "a";
        escapeTime = 0;
        keyMode = "vi";
      };

      vscode = {
        enable = true;
        package = pkgs.vscodium;
        userSettings = {
          "update.mode" = "none";
          "files.associations" = {
            "**.yaml.gotmpl" = "helm";
            "helmfile.yaml" = "helm";
          };
          "explorer.confirmDelete" = false;
	        "explorer.confirmDragAndDrop" = false;
          "editor.formatOnSave" = true;
          "git.confirmSync" = false;
          "todo-tree.regex.regex" = "(//|#|<!--|;|/\\*|^|^\\s*(-|\\d+.))\\s*($TAGS)";
          "todo-tree.general.tags" = [
            "BUG"
            "HACK"
            "FIXME"
            "TODO"
            "XXX"
            "[ ]"
            "[x]"
          ];
          "terminal.integrated.commandsToSkipShell" = [
	          "-workbench.action.quickOpen" # ctrl-p
          ];
        };
        extensions = with pkgs.vscode-extensions; [
          # dendron
          ms-python.python
	        eamodio.gitlens
          # rest-client
          # xonsh
          bbenoist.Nix
	        formulahendry.code-runner
	        haskell.haskell
          golang.Go
          gruntfuggly.todo-tree
          james-yu.latex-workshop
          ms-kubernetes-tools.vscode-kubernetes-tools
          redhat.vscode-yaml
          vscodevim.vim
          hashicorp.terraform
        ];
        keybindings = [
          {
            key = "ctrl+a c";
            command = "workbench.action.terminal.newInActiveWorkspace";
          }
          { key = "ctrl+a o";
            command = "workbench.action.terminal.focus";
          }
          { 
            key = "ctrl+a o";
            command = "workbench.action.focusActiveEditorGroup";
            when = "terminalFocus";
          }
          {
            key = "ctrl+a z";
            command = "workbench.action.toggleMaximizedPanel";
            when = "terminalFocus";
          }
          {
            key = "ctrl+a n";
            command = "workbench.action.terminal.focusNext";
            when = "terminalFocus";
          }
          {
            key = "ctrl+a p";
            command = "workbench.action.terminal.focusPrevious";
            when = "terminalFocus";
          }
          {
            key = "ctrl+a shift+'";
            command = "workbench.action.terminal.split";
            when = "terminalFocus && panelPosition != 'bottom'";
          }
          {
            key = "ctrl+a shift+5";
            command = "workbench.action.terminal.split";
            when = "terminalFocus && panelPosition == 'bottom'";
          }
        ];
      };

      neovim = {
        enable = true;
        viAlias = true;
        vimAlias = true;
        # plugins = [];
      };

    };

  };

}
