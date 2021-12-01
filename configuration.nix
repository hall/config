{ pkgs, mach-nix, ... }:
let
  # xontribs = [
  #   # "argcomplete" # tab completion of python and xonsh scripts
  #   # "sh" # prefix (ba)sh commands with "!"
  #   # "autojump" or "z"   # autojump support(or zoxide?)
  #   # "autoxsh" or "direnv"     # execute .autoxsh when entering directory
  #   # "onepath" # act on file/dir by only using its name
  #   # "prompt_starship"
  #   # "pipeliner" # use "pl" to pipe a python expression
  # ];

  # pyenv = mach-nix.mkPython {
  #   requirements = ''
  #     black
  #   ''; #+ builtins.toString (map (x: "xontrib-" + x) xontribs);
  #     # pylint
  #     # numpy
  #     # pip
  #     # xxh-xxh
  # };

in
{
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
      allow-unsafe-native-code-during-evaluation = true
    '';
  };

  musnix.enable = true;
  hardware = {
    pulseaudio.enable = false;
    i2c.enable = true;
  };

  boot.loader.systemd-boot.enable = true;

  time.timeZone = "America/New_York";

  networking = {
    hostName = "rigetti";
    # wireless.enable = true;
    interfaces = {
      enp0s13f0u3u1.useDHCP = true;
      enp0s31f6.useDHCP = true;
      wlp0s20f3.useDHCP = true;
    };
    firewall = {
      enable = true;
      allowedTCPPorts = [
        1716 # gsconnect
        24800 # barrier
        # 5900 # vnc
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

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    useXkbConfig = true;
  };

  services = {
    xserver = {
      enable = true;
      desktopManager.gnome.enable = true;
      displayManager = {
        gdm.enable = true;
        autoLogin = {
          enable = true;
          user = "bryton";
        };
      };
      layout = "us";
      xkbVariant = "dvorak";
      libinput.touchpad.tapping = true;
    };
    # ddccontrol.enable = true;
    interception-tools = {
      enable = true; # TODO: device-specific activation
      plugins = with pkgs.interception-tools-plugins; [
        caps2esc
      ];
      # https://github.com/NixOS/nixpkgs/issues/126681
      udevmonConfig = with pkgs; ''
        - JOB: "${interception-tools}/bin/intercept -g $DEVNODE | ${interception-tools-plugins.caps2esc}/bin/caps2esc | ${interception-tools}/bin/uinput -d $DEVNODE"
          DEVICE:
            EVENTS:
              EV_KEY: [KEY_CAPSLOCK, KEY_ESC]
      '';
    };
    printing.enable = true;
    # avahi = {
    #   enable = true;
    #   nssmdns = true;
    # };

    fprintd = {
      enable = true;
    };
    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
      jack.enable = true;
    };
    # globalprotect.enable = true;
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
      "dialout"
      "docker"
      "i2c"
      "input"
      "wheel"
      #"wireshark"
    ];
  };

  sound.enable = true;

  environment = {
    # systemPackages = with pkgs; [ ];
    gnome.excludePackages = with pkgs; [
      gnome.cheese
      gnome.gnome-music
      gnome.gedit
      epiphany
      gnome.gnome-characters
    ];
  };

  security = {
    sudo.extraRules = [
      {
        users = [ "bryton" ];
        commands = [{ command = "ALL"; options = [ "NOPASSWD" ]; }];
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

  programs = {
    bash.enableCompletion = true;
    dconf.enable = true;
    wireshark.enable = true;
    gnupg.agent = {
      enable = true;
      pinentryFlavor = "gnome3";
    };
  };
}
