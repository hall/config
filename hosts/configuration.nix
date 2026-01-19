{ config, lib, pkgs, flake, ... }:
let
  systemParts = lib.splitString "-" pkgs.stdenv.hostPlatform.system;
  arch = lib.elemAt systemParts 0;
  platform = lib.elemAt systemParts 1;
in
{
  # https://nixos.org/manual/nixos/stable/release-notes.html
  # https://nix-community.github.io/home-manager/release-notes.xhtml
  system.stateVersion = "24.11";

  imports = [
    ./nix.nix
    ./home.nix
  ];

  age.rekey = {
    masterIdentities = [ "/home/${flake.lib.username}/.ssh/id_ed25519" ];
    # force secrets to be copied to remote host
    derivation = flake.nixosConfigurations.${config.networking.hostName}.config.age.rekey.derivation;
    storageMode = "local";
    localStorageDir = ./. + "/${platform}/${arch}/${config.networking.hostName}/.secrets";
  };

  security.sudo.execWheelOnly = true;

  environment = {
    defaultPackages = lib.mkForce (with pkgs; [
      vim
      tmux
    ]);
    sessionVariables = {
      EDITOR = "vim";
      NIXOS_OZONE_WL = "1";
      # krita fails to open
      #https://github.com/NixOS/nixpkgs/issues/82959#issuecomment-657306112
      QT_XCB_GL_INTEGRATION = "none";
    };
  };

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  services = {
    pcscd.enable = true;
    udev.packages = with pkgs; [ yubikey-personalization ];
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
      xkb = {
        layout = "us";
        variant = "dvorak";
      };
      autoRepeatInterval = 100;
      autoRepeatDelay = 200;
    };
  };

  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  hardware.enableRedistributableFirmware = true;

  users = {
    mutableUsers = false;
    users.${flake.lib.username} = {
      isNormalUser = true;
      uid = 1000;
      hashedPassword = "$y$j9T$fUivdhuwqeMf6/iNYRX92/$sbxbgkQRAoD0uB9bcmYYC/7gssMAu.ZRk.JLU4qfmpA"; # `mkpasswd`
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE/nxzI9MwJC1gMWCNDzdGUZsRvsCdNBqaH5iJwreqHc" # /secrets/id_ed25519.age
      ];
      group = "users";
      extraGroups = [
        "adbusers"
        "audio"
        "video"
        "input"
        "dialout"
        "docker"
        "i2c"
        "wheel"
        "networkmanager"

        "libvirtd"
      ];
    };
  };

}
