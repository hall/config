{ config, lib, pkgs, flake, age, specialArgs, ... }:
let
  xontribs = [
    # "argcomplete" # tab completion of python and xonsh scripts
    "sh" # prefix (ba)sh commands with "!"
    # "onepath" # act on file/dir by only using its name # TODO: build failed
    "pipeliner" # use "pl" to pipe a python expression
    "zoxide"
    "prompt-starship"
    # "readable-traceback"
  ];
  pyenv = flake.inputs.mach.lib.${pkgs.system}.mkPython {
    python = "python310";
    requirements = ''
      # black
      # numpy
      # pandas

      xxh-xxh
      # xxh-shell-xonsh
      xonsh-direnv
    '' + builtins.toString (map (x: "xontrib-" + x + "\n") xontribs);
  };
  xonsh = pkgs.xonsh.overrideAttrs (super: {
    pythonPath = pyenv.selectPkgs pyenv.python.pkgs;
  });
in
{
  home-manager = let homeFile = /${specialArgs.hostPath}/home.nix; in
    if (builtins.pathExists homeFile) then {
      useGlobalPkgs = true;
      useUserPackages = true;
      users.${flake.lib.username} =
        with builtins; with lib.trivial; pipe [
          ./home
          /${specialArgs.hostPath}/home.nix
        ] [ (map import) lib.mkMerge ];
      extraSpecialArgs = specialArgs;
    } else { };

  # https://nixos.org/manual/nixos/stable/release-notes.html
  system.stateVersion = "22.11";

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "vscode-extension-ms-toolsai-jupyter"
    "vscode-extension-ms-vscode-cpptools"
    "vscode-extension-github-copilot"
    "steam"
    "steam-original"
    "steam-runtime"
    "steam-run"
  ];

  age.secretsDir = "/run/secrets";

  security.sudo.execWheelOnly = true;

  environment = {
    defaultPackages = lib.mkForce (with pkgs; [
      vim
      tmux
    ]);
    sessionVariables = {
      MOZ_USE_XINPUT2 = "1";
      EDITOR = "vim";
    };

    gnome.excludePackages = with pkgs; [
      epiphany # browser
      gnome-tour
      gnome-passwordsafe
    ] ++ (with gnome;[
      cheese
      gnome-music
      gnome-notes
      gedit
      seahorse # passwords
      gnome-characters
      gnome-user-docs
    ]);
  };

  services = {
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };
      # allowSFTP = false;
      extraConfig = ''
        AllowTcpForwarding yes
        X11Forwarding no
        AllowAgentForwarding no
        AllowStreamLocalForwarding no
        AuthenticationMethods publickey
      '';
    };
    xserver = {
      enable = true;
      layout = "us";
      xkbVariant = "dvorak";
      autoRepeatInterval = 100;
      autoRepeatDelay = 200;
      excludePackages = with pkgs; [ xterm ];
    };
  };


  nix = {
    gc = {
      automatic = false;
      options = "--delete-older-than 30d";
    };
    extraOptions = ''
      # https://github.com/nix-community/nix-direnv#installation
      keep-outputs = true
      keep-derivations = true
      # useful when builder has faster network
      builders-use-substitutes = true
    '';
    settings = {
      experimental-features = "nix-command flakes";
      trusted-users = [ "root" flake.lib.username ];
      trusted-public-keys = [
        "hydra.nixos.org-1:CNHJZBh9K4tP3EKF6FkkgeVYsS3ohTl+oS0Qa8bezVs="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      trusted-substituters = [
        "https://hydra.nixos.org"
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];
    };

    distributedBuilds = true;
    buildMachines = [{
      hostName = "tv";
      sshUser = flake.lib.username;
      sshKey = "/run/secrets/id_ed25519";
      systems = [ "x86_64-linux" "aarch64-linux" ];
      maxJobs = 8;
      supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
    }];
  };

  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  hardware.enableRedistributableFirmware = true;

  programs.xonsh = {
    enable = true;
    package = xonsh;
    config = with builtins; ''
      $BASH_COMPLETIONS = ["${pkgs.bash-completion}/share/bash-completion/bash_completion"]
      $VI_MODE = True

      xontrib load direnv ${toString (map (x: replaceStrings [ "-" ] [ "_" ] x) xontribs)}

      $GOPATH = $HOME
      
      aliases |= {
          "k": ["kubectl"],
          "cd": ["z"],
      }
    '';
  };

  users.users.${flake.lib.username} = {
    isNormalUser = true;
    shell = config.programs.xonsh.package;
    extraGroups = [
      "audio"
      "dialout"
      "docker"
      "i2c"
      "input"
      "wheel"
      #"wireshark"

      "feedbackd"
      "video"
      "networkmanager"
    ];
  };
}
