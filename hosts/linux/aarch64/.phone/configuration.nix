{ pkgs, musnix, flake, lib, modulesPath, ... }: {
  # nix build '.#nixosConfigurations.phone.config.mobile.outputs.android.android-fastboot-images'

  imports = [
    (import "${flake.inputs.mobile}/lib/configuration.nix" { device = "oneplus-enchilada"; })
  ];

  fileSystems."/" = {
    device = lib.mkForce "/dev/disk/by-label/NIXOS_SYSTEM";
    fsType = "ext4";
  };

  # mobile.beautification = {
  #   silentBoot = lib.mkDefault true;
  #   splash = lib.mkDefault true;
  # };

  hardware.sensor.iio.enable = true;
  virtualisation = {
    waydroid.enable = true;
    lxd.enable = true;
  };


  users.users = {
    geoclue.extraGroups = [ "networkmanager" ];
    ${flake.lib.username}.initialPassword = "1234";
  };
  # musnix.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-gnome ];
  };

  # TODO: https://github.com/NixOS/mobile-nixos/blob/master/modules/quirks/qualcomm/sdm845-modem.nix
  systemd.services.msm-modem-uim-selection.enable = lib.mkForce false;

  # services.xserver.enable = true;
  # services.xserver.videoDrivers = [ ];
  # services.xserver.displayManager.gdm.enable = true;
  # services.xserver.desktopManager.gnome.enable = true;

  # services.fprintd = {
  #   enable = true;
  #   package = pkgs.fprintd-tod;
  #   tod = {
  #     enable = true;
  #     driver = pkgs.libfprint-2-tod1-goodix;
  #   };
  # };


  services = {
    gnome.gnome-keyring.enable = true;
    # effects = {
    #   enable = true;
    #   kernel = "controlC3";
    # };

    fwupd.enable = true;

    # TODO: not sure why this is enabled

    xserver = {
      enable = true;
      videoDrivers = [ ];
      displayManager.gdm.enable = true;
      # displayManager.lightdm.enable = lib.mkForce false;
      desktopManager.phosh = {
        enable = true;
        user = flake.lib.username;
        group = "users";
        # for better compatibility with x11 applications
        phocConfig.xwayland = "immediate";
      };
    };

    geoclue2 = {
      # enable = true;
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

  # i18n.inputMethod.enabled = "ibus";
  # i18n.inputMethod.ibus.engines = with pkgs.ibus-engines; [ libpinyin anthy ];

  programs.calls.enable = true;

  location.provider = "geoclue2";

  # environment.variables = {
  #   WEBKIT_FORCE_SANDBOX = "0"; # workaround for epiphany
  # };

  home = {
    enable = true;
    packages = with pkgs; [
      # logseq # TODO: add arch support
      phosh-mobile-settings
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
      valent

      gnome-podcasts
      gnome-photos
    ] ++ (with pkgs.gnome; [
      geary # email
      totem # videos
      gedit # editor
      nautilus # files
      eog # images
      fractal-next # matrix
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
      # gnome-todo
      gnome-notes
      # gnome-books
      gnome-screenshot
      gnome-dictionary
      gnome-disk-utility
      # firefox-mobile
      # bitwarden
    ]) ++ (with flake.packages; [
      # effects
    ]);

    # services.gammastep = {
    #   enable = true;
    #   # provider = "geoclue";
    #   latitude = 40.0;
    #   longitude = -77.0;
    # };
    programs = {
      # firefox.enable = lib.mkForce false;
      firefox.profiles.default.settings = {
        "general.useragent.override" = "Mozilla/5.0 (Android 11; Mobile; rv:96.0) Gecko/96.0 Firefox/96.0";
      };
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

  # # https://github.com/NixOS/mobile-nixos/pull/542
  # mobile.kernel.structuredConfig = [
  #   # Needed for waydroid
  #   (helpers: with helpers; let
  #     inherit (lib) mkMerge;
  #     # TODO drop when we fix modular kernels
  #     module = yes;
  #   in
  #   {
  #     # ANDROID = whenBetween "3.19" "6.0" yes;
  #     ANDROID = whenAtLeast "3.19" yes;
  #     ANDROID_BINDER_IPC = whenAtLeast "3.19" yes;
  #     ANDROID_BINDERFS = whenAtLeast "5.0" yes;

  #     # Needed for waydroid networking to function
  #     NF_TABLES = whenAtLeast "3.13" yes;
  #     NF_TABLES_IPV4 = mkMerge [ (whenBetween "3.13" "4.17" module) (whenAtLeast "4.17" yes) ];
  #     NF_TABLES_IPV6 = mkMerge [ (whenBetween "3.13" "4.17" module) (whenAtLeast "4.17" yes) ];
  #     NF_TABLES_INET = mkMerge [ (whenBetween "3.14" "4.17" module) (whenAtLeast "4.17" yes) ];
  #     NFT_MASQ = whenAtLeast "3.18" module;
  #     NFT_NAT = whenAtLeast "3.13" module;
  #     IP_ADVANCED_ROUTER = yes;
  #     IP_MULTIPLE_TABLES = yes;
  #     IPV6_MULTIPLE_TABLES = yes;

  #     # Needed for XfrmController
  #     XFRM = yes;
  #     XFRM_ALGO = whenAtLeast "3.5" module;
  #     XFRM_USER = module;

  #     # netd uses NFLOG
  #     NETFILTER_NETLINK = yes;
  #     NETFILTER_NETLINK_LOG = yes;
  #     NETFILTER_XT_TARGET_NFLOG = module;
  #   })
  # ];

}
