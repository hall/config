# NUC11PAHi7, 88:AE:DD:05:C9:46, F2 and/or ESC to enter bios
# TODO
# - circadian lighting
# - connect
#   - switches: https://www.indiegogo.com/projects/mmwave-smart-switch-with-presence-sensing-radar
#   - led controllers
#   - konnected: https://www.reddit.com/r/konnected/comments/15pom5f/any_update_on_matter_support/
#   - power monitoring?
#   - mailbox?
{ lib, pkgs, flake, config, ... }: {
  boot = {
    # TODO: remove? no longer have any aarch64 targets
    # binfmt.emulatedSystems = [ "aarch64-linux" ];
    # for 8bitdo pro 2 in switch mode
    blacklistedKernelModules = [ "hid-nintendo" ];
  };

  nixpkgs.config.packageOverrides = pkgs: {
    intel-vaapi-driver = pkgs.intel-vaapi-driver.override { enableHybridCodec = true; };
  };
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      libvdpau-va-gl
      vpl-gpu-rt
    ];
  };
  environment.sessionVariables = {
    # Force intel-media-driver
    LIBVA_DRIVER_NAME = "iHD";
    KODI_AE_SINK = "PULSE";
  };

  systemd.services = {
    "getty@tty1".enable = false;
    "autovt@tty1".enable = false;
  };

  imports = [
    ./home.nix
    ./media.nix
    # ./gnome.nix
    ./kodi.nix
    # ./cage.nix
    flake.inputs.hardware.nixosModules.intel-nuc-8i7beh
  ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  networking = {
    firewall = {
      allowedTCPPorts = [
        80 # http redirect
        443 # https
        53 # dns fallback
        8080 # kodi
        5900 # vnc
      ];
      allowedUDPPorts = [
        53 # dns
        67 # dhcp
        68 # dhcp
        9777 # kodi event server
      ];
    };
  };

  age = {
    # rekey.hostPubkey = (builtins.head config.nix.buildMachines).publicHostKey;
    rekey.hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFt04Q7AY48Q5tJxFPxjJ3BZpBaR++R0jHRq7JVtBbkL";
    secrets = {
      namecheap.rekeyFile = ./namecheap.age;
      restic.rekeyFile = ./restic.age;
      rclone.rekeyFile = ./rclone.age;
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults = {
      email = flake.lib.email;
      group = "nginx";
      dnsProvider = "namecheap";
      environmentFile = config.age.secrets.namecheap.path;
    };
    certs."${flake.lib.hostname}".domain = "*.${flake.lib.hostname}";
  };

  systemd.services = {
    cec-toggle.serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "cec-toggle" ''
        if ${pkgs.procps}/bin/pgrep kodi &> /dev/null 2>&1; then
          ${pkgs.curl}/bin/curl --silent -X POST -H 'Content-Type: application/json' http://localhost:8080/jsonrpc -d '${builtins.toJSON {
            id = 1;
            jsonrpc = "2.0";
            method = "Addons.ExecuteAddon";
            params = {
              addonid = "script.json-cec";
              params.command = "toggle";
            };
          }}'
        else
          if echo pow 0 | ${pkgs.libcec}/bin/cec-client -s -d 1 | ${pkgs.gnugrep}/bin/grep -q "status: on"; then
            COMMAND=standby
          fi
          echo ''${COMMAND:-on} 0 | ${pkgs.libcec}/bin/cec-client -s -d 1
        fi
      '';
    };
  };
  hardware = {
    xpadneo.enable = true;
    steam-hardware.enable = true;
  };

  services = {
    udev.packages = with pkgs;[
      # for 8bit pro 2 in switch mode
      game-devices-udev-rules
    ];
    keyd = {
      enable = true;
      keyboards = {
        gamepad = {
          # 8BitDo Pro 2
          ids = [
            # "057e:2009" # switch mode
            # "0fac:0ade" # "keyd virtual keyboard"
            "*"
          ];
          settings = {
            main = {
              "f3" = "command(systemctl start cec-toggle)";
            };
          };
        };
      };
    };
    displayManager.autoLogin = {
      enable = true;
      user = flake.lib.username;
    };

    wifi.enable = true;
    # tailscale = {
    #   enable = true;
    #   extraUpFlags = [ "--ssh" ];
    # };

    adguardhome = {
      enable = true;
      mutableSettings = false;
      settings = {
        dns = {
          bind_host = "127.0.0.1";
          bootstrap_dns = [
            "9.9.9.10"
            "149.112.112.10"
            "2620:fe::10"
            "2620:fe::fe:10"
          ];
        };
        filtering = {
          rewrites = [{
            domain = "*.${flake.lib.hostname}";
            answer = "192.168.86.2";
          }];
        };
        dhcp = {
          enabled = false;
          interface_name = "wlo1";
          dhcpv4 = {
            gateway_ip = "192.168.86.1";
            subnet_mask = "255.255.255.0";
            range_start = "192.168.86.10";
            range_end = "192.168.86.254";
          };
        };
      };
    };

    nginx = {
      enable = true;
      logError = "stderr debug";
      # recommendedGzipSettings = true;
      # recommendedOptimisation = true;
      # recommendedProxySettings = true;
      # recommendedTlsSettings = true;

      virtualHosts = {
        "adguard.${flake.lib.hostname}" = {
          useACMEHost = flake.lib.hostname;
          acmeRoot = null;
          forceSSL = true;
          locations."/".proxyPass = "http://127.0.0.1:3000";
        };
        "sync.${flake.lib.hostname}" = {
          useACMEHost = flake.lib.hostname;
          acmeRoot = null;
          forceSSL = true;
          locations."/".proxyPass = "http://${builtins.toString config.services.syncthing.guiAddress}";
          extraConfig = ''
            proxy_read_timeout      600s;
            proxy_send_timeout      600s;
          '';
        };
        "stash.${flake.lib.hostname}" = {
          useACMEHost = flake.lib.hostname;
          acmeRoot = null;
          forceSSL = true;
          locations."/".proxyPass = "http://127.0.0.1:${builtins.toString config.services.stash.port}";
          extraConfig = ''
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_read_timeout 60000s;
          '';
        };
      };
    };

    stash = {
      # /var/lib/stash  # app data
      enable = true;
      user = flake.lib.username;
      group = "syncthing";
    };

    syncthing.settings.folders.stash.path = lib.mkForce "/var/lib/stash";

    # manually trigger with: `systemctl start restic-backups-remote`
    # restic -r rclone:remote:/backups restore <id> --target <path>
    # restic mount ...
    # rclone about remote:
    restic.backups.remote = {
      initialize = true;
      paths = lib.mapAttrsToList (name: folder: folder.path) config.services.syncthing.settings.folders;
      repository = "rclone:gdrive:/backup";
      passwordFile = config.age.secrets.rclone.path;
      environmentFile = config.age.secrets.restic.path;
      extraBackupArgs = [ "--fast-list" ];
      timerConfig.OnCalendar = "sunday 23:00";
    };

    # iperf3 = {
    #   enable = true;
    #   openFirewall = true;
    # };
    # input-remapper = {
    #   enable = true;
    # };
  };

  environment.systemPackages = with pkgs; [
    # iperf
    # htop
    libcec
    # for steam-launcher
    wmctrl
    xdotool
    dconf
    # / for steam-launcher
    lutris
    # (pkgs.kodi-wayland.passthru.withPackages (kodiPkgs: with kodiPkgs; [
    #   # artic: zephyr - reloaded
    #   netflix
    #   # disney+
    #   # hulu
    #   # crunchyroll
    #   joystick
    #   youtube
    #   steam-library
    #   # steam-launcher # doesn't work?
    #   libretro
    # ]))
  ];

}
