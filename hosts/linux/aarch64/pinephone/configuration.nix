{ pkgs, musnix, flake, lib, modulesPath, ... }: {

  imports = [
    (import "${flake.inputs.mobile}/lib/configuration.nix" { device = "pine64-pinephonepro"; })
    (modulesPath + "/installer/sd-card/sd-image-aarch64.nix")
  ];

  fileSystems."/home" = {
    device = "/dev/disk/by-label/home";
    fsType = "ext4";
  };

  boot = {
    # overwrite nixos-generators setting with the one from nixos-mobile
    loader.generic-extlinux-compatible.enable = lib.mkForce true;
    postBootCommands = ''
      # usb audio interface does not work in the default `device` mode
      # and automatic mode switching is not functional
      echo host | tee /sys/class/usb_role/fe800000.usb-role-switch/role
    '';
  };

  hardware.sensor.iio.enable = true;

  users.users = {
    geoclue.extraGroups = [ "networkmanager" ];
    ${flake.lib.username}.initialPassword = "1234";
  };
  musnix.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-gnome ];
  };

  services = {
    gnome.gnome-keyring.enable = true;
    effects = {
      enable = true;
      kernel = "controlC3";
    };
    # wifi.enable = true;

    fwupd.enable = true;
    flatpak = {
      enable = true;
      # dialect
      # bitwarden
    };

    # TODO: not sure why this is enabled
    xserver.displayManager.lightdm.enable = lib.mkForce false;
    xserver.desktopManager.phosh = {
      enable = true;
      user = flake.lib.username;
      group = "users";
      # for better compatibility with x11 applications
      phocConfig.xwayland = "immediate";
    };

    geoclue2 = {
      enable = true;
      # appConfig = {
      #   gammastep = {
      #     isAllowed = true;
      #     isSystem = true;
      #     users = [ "1000" ];
      #   };
      #   "sm.puri.Phosh" = {
      #     isAllowed = true;
      #     isSystem = true;
      #   };
      # };
    };
  };

  programs.calls.enable = true;

  location.provider = "geoclue2";

  environment.variables = {
    WEBKIT_FORCE_SANDBOX = "0"; # workaround for epiphany
  };

  home = {
    enable = true;
    packages = with pkgs; [
      # purple-matrix
      # purple-slack
      # tdlib-purple
      pinentry-gnome
      jellyfin-media-player

      lingot
      itd
      koreader

      chatty
      megapixels
      epiphany
      newsflash

      guitarix
      spot
      drawing
      fragments
      # banking
      tootle
      # waydroid
      pure-maps
      # siglo
      # ardour
      foliate

      usbutils
      libusb1
      # valent

      gnome-podcasts
      gnome-photos
    ] ++ (with pkgs.gnome; [
      geary # email
      totem # videos
      gedit # editor
      nautilus # files
      eog # images
      # fractal-next # matrix
      giara # reddit

      gnome-terminal
      # gnome-connections
      gnome-calendar
      gnome-contacts
      gnome-calculator
      gnome-clocks
      #gnome-documents # broken
      gnome-maps
      gnome-music
      gnome-weather
      gnome-system-monitor
      gnome-sound-recorder
      gnome-todo
      gnome-notes
      # gnome-books
      gnome-screenshot
      gnome-dictionary
      gnome-disk-utility
      firefox-mobile
    ]) ++ (with flake.packages; [
      effects
    ]);

    services.gammastep = {
      enable = true;
      # provider = "geoclue";
      latitude = 40.0;
      longitude = -77.0;
    };

    programs = {
      firefox.enable = lib.mkForce false;
      vscode = {
        userSettings = {
          "editor.folding" = false;
          "editor.minimap.enabled" = false;
          "editor.glyphMargin" = false;
          "git.decorations.enabled" = false;
          "editor.scrollbar.vertical" = "hidden";
          # "workbench.editor.splitInGroupLayout" = "vertical";
          "workbench.editor.openSideBySideDirection" = "down";
        };
        extensions = pkgs.vscode-utils.extensionsFromVscodeMarketplace [
          {
            name = "toggle-zen-mode";
            publisher = "fudd";
            version = "1.1.2";
            sha256 = "sha256-ug1LVun0StMwpWfbtWmkpIVyvTr/ukKwxSEHG+1dFXI=";
          }
        ];
      };
    };
  };

}
