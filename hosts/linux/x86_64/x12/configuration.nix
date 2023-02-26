{ config, pkgs, musnix, flake, ... }:
{
  boot.binfmt.emulatedSystems = [
    "aarch64-linux"
  ];

  laptop.enable = true;
  hardware.opengl.enable = true;

  musnix.enable = true;
  programs.steam.enable = true;
  # wireguard.enable = true;

  networking = {
    firewall = {
      checkReversePath = "loose";
      allowedTCPPorts = [
        1716 # gsconnect
      ];
      allowedUDPPorts = [
        51820 # wg
      ];
    };
    wg-quick.interfaces.wg0 = {
      address = [ "10.1.0.2/24" ];
      dns = [ "10.0.0.1" ];
      listenPort = 51820;
      privateKeyFile = "/run/secrets/wg";
      peers = [{
        endpoint = "vpn.${flake.hostname}:51820";
        allowedIPs = [ "0.0.0.0/0" ];
        publicKey = "bt2nzOAO+ArOj5KQRI9c5pphmazcCZmiWvo/TeP3n3M=";
        persistentKeepalive = 25;
      }];
    };
    networkmanager.dispatcherScripts = [{
      source = pkgs.writeText "upHook" ''
        export PATH=$PATH:/run/current-system/sw/bin
        # if in range of home network
        if [[ nmcli -t -f SSID device wifi | grep hall ]]; then
          setting=false
        fi
        su -l ${flake.username} -c "dbus-launch dconf write /org/gnome/desktop/screensaver/lock-enabled ''${setting:-true}"
      '';
    }];
  };

  services = {
    printing.enable = true;
    effects = {
      enable = true;
      kernel = "controlC1";
    };
    # wifi.enable = true;
    xserver.wacom.enable = true;
    udev.packages = [ pkgs.qmk-udev-rules ];
  };

  age.secrets = {
    wg.file = ../../../../secrets/wg_${config.networking.hostName}.age;
    id_ed25519 = {
      file = ../../../../secrets/id_ed25519.age;
      path = "${config.users.users.${flake.username}.home}/.ssh/id_ed25519";
      owner = flake.username;
    };

    # openwrt doesn't support ed25519
    id_rsa = {
      file = ../../../../secrets/id_rsa.age;
      path = "${config.users.users.${flake.username}.home}/.ssh/id_rsa";
      owner = flake.username;
    };

    github = {
      file = ../../../../secrets/github.age;
      owner = flake.username;
    };

    gitlab = {
      file = ../../../../secrets/gitlab.age;
      owner = flake.username;
    };

    kubeconfig = {
      file = ../../../../secrets/kubeconfig.age;
      owner = flake.username;
    };

    kubenix = {
      file = ../../../../secrets/kubenix.age;
      owner = flake.username;
    };
  };

}
