{ lib, config, pkgs, ... }:

let
  home-manager = builtins.fetchGit {
    url = "https://github.com/rycee/home-manager.git";
    rev = "35a24648d155843a4d162de98c17b1afd5db51e4";
    ref = "release-21.05";
  };

  py-packages = pkgs.python3.withPackages (python-packages: with python-packages; [
    pandas
    pip
    setuptools
  ]);

in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      (import "${home-manager}/nixos")
    ];


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
  };

  console = {
    useXkbConfig = true;
  };

  services = {
    xserver = {
      enable = true; 
      displayManager.gdm.enable = true;
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
    };
  };

  virtualisation = {
    docker.enable = true;
  };

  users.users.bryton = {
    isNormalUser = true;
    shell = pkgs.xonsh;
    extraGroups = [
      "audio"
      "adbusers"
      "docker"
      "input"
      "wheel"
      "wireshark"
    ];
  };

  security.sudo.extraRules = [
    {
      users = [ "bryton" ];
      commands = [ { command = "ALL"; options = [ "NOPASSWD" ]; } ];
    }
  ];

  environment = {
    variables = {
      EDITOR = "nvim";
    };
    systemPackages = with pkgs; [
      curl
      gnomeExtensions.gsconnect
    ];
  };

  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05";


  nixpkgs.config.packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
  };

  programs = {
    dconf.enable = true;
    wireshark.enable = true;
    adb.enable = true;
    xonsh = {
      enable = true;
      config = builtins.readFile ./xonshrc;
    };

  };

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "zoom"
  ];

  home-manager.users.bryton = {
    home.packages = with pkgs; [
      #fprintd-tod
      #libfprint-tod
      bitwarden-cli
      rsync
      etcher
      gnupg
      nextcloud-client
      ripgrep
      usbutils
      wireshark
      xonsh
      inotify-tools
      
      # comms
      #slack-dark
      ferdi
      tdesktop
      zoom-us

      # gnome
      gnome.dconf-editor
      gnome.gnome-todo
      gnome3.gnome-tweaks
      gnomeExtensions.gnome-shell-extension-bluetooth-quick-connect
      gnomeExtensions.gnome-shell-extension-nasa-apod
      gnomeExtensions.gnome-shell-extension-night-light-slider

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
      py-packages
      ## node
      yarn

      # containers
      docker
      docker-compose
      helmfile
      k3s
      kubectl
      kubernetes-helm
      kubie
      lens

      # tmux
      tmuxPlugins.nord
      tmuxPlugins.sensible
      tmuxPlugins.vim-tmux-navigator

      # design
      ardour
      openscad
      prusa-slicer
      xournalpp

    ];

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
         "org/gnome/mutter" = {
           workspaces-only-on-primary = false;
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
      };

      firefox = {
        enable = true;
        profiles = {
          default = {
            id = 0;
            name = "default";
            settings = {
              "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
              "browser.search.defaultenginename" = "duckduckgo";
              "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
              "signon.rememberSignons" = false;
              "devtools.theme" = "dark";
            };
            userChrome = builtins.readFile ./userChrome.css;
            userContent = builtins.readFile ./userContent.css;
          };
        };
        extensions = with pkgs.nur.repos.rycee.firefox-addons; [
          anchors-reveal
          auto-tab-discard
          #buster
          bypass-paywalls
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
          "files.associations" = {
            "**.yaml.gotmpl" = "helm";
          };
          "explorer.confirmDelete" = false;
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
        };
        extensions = with pkgs.vscode-extensions; [
          # dendron
          # ms-python.python
          # ms-toolsai.jupyter
          # rest-client
          # xonsh
          bbenoist.Nix
          golang.Go
          gruntfuggly.todo-tree
          james-yu.latex-workshop
          ms-kubernetes-tools.vscode-kubernetes-tools
          redhat.vscode-yaml
          vscodevim.vim
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
