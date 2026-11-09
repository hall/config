{ lib, flake, ... }:
let
  network = import ./network.nix;

  # imported by every device
  common =
    {
      config,
      lib,
      pkgs,
      name,
      ...
    }:
    {
      # anonymous sections are lists, which can't be overridden per key
      options.system = lib.mkOption {
        type =
          with lib.types;
          attrsOf (oneOf [
            bool
            int
            str
          ]);
        description = "Options for the anonymous `system.@system[0]` section.";
      };

      # dewclaw has no service toggles, and rc.d links aren't UCI so a reflash loses them
      options.disabledServices = lib.mkOption {
        type = with lib.types; listOf str;
        default = [ ];
        description = "Init scripts to disable and stop on every deploy.";
      };

      config = {
        # by IP: names come from DHCP, so they vanish from DNS while a device reboots
        deploy.host = network.hosts.${name}.ip or network.lan.address;
        # keep using the known_hosts entries recorded under the device name
        deploy.sshConfig.HostKeyAlias = name;

        # secrets are a JSON object encrypted to the same key agenix-rekey uses
        secretsCommand = pkgs.writeShellScript "openwrt-secrets" ''
          ${lib.getExe pkgs.rage} -d -i "$HOME/.ssh/id_ed25519" ${./secrets.json.age}
        '';

        # dewclaw writes with echo, which adds the trailing newline
        etc."dropbear/authorized_keys".text = flake.lib.sshKey;
        users.root.hashedPasswordSecret = "root_pw";
        # dewclaw leaves the (world-readable) hash in /tmp
        deploySteps.rootPassword.apply = lib.mkAfter "rm -f /tmp/root_hash";

        deploySteps.disabledServices = lib.mkIf (config.disabledServices != [ ]) {
          # after uciConfig (90), so nothing later re-enables them
          priority = 95;
          apply = lib.concatMapStrings (svc: ''
            /etc/init.d/${svc} disable
            /etc/init.d/${svc} stop || true
          '') config.disabledServices;
        };

        packages = [
          "prometheus-node-exporter-lua"
          "prometheus-node-exporter-lua-netstat"
          "prometheus-node-exporter-lua-openwrt"
        ];

        uci.retain = [
          "attendedsysupgrade"
          "luci"
          "rpcd"
          "ubootenv"
          "ucitrack"
          "uhttpd"
        ];

        system = lib.mapAttrs (_: lib.mkDefault) {
          hostname = name;
          timezone = "GMT0";
          zonename = "UTC";
          ttylogin = false;
          log_size = 128;
          urandom_seed = false;
          # TODO: log_ip once server is back
          log_proto = "udp";
          conloglevel = 8;
          cronloglevel = 7;
        };

        uci.settings = {
          dropbear.dropbear.main = {
            enable = true;
            # keys only; the root password is still the LuCI login
            PasswordAuth = "off";
            RootPasswordAuth = "off";
            Port = 22;
          };

          network.interface.loopback = {
            device = "lo";
            proto = "static";
            ipaddr = "127.0.0.1/8";
          };

          "prometheus-node-exporter-lua"."prometheus-node-exporter-lua".main = {
            listen_interface = "lan";
            listen_port = 9100;
          };

          system = {
            system = [ config.system ];
            # by IP: without a local dnsmasq, ntpd's jail snapshots an empty
            # resolv.conf at boot and never resolves hostnames
            timeserver.ntp.server = lib.mkDefault [ network.lan.address ];
          };
        };
      };
    };
in
{
  openwrt =
    lib.mapAttrs
      (_: path: {
        imports = [
          common
          path
        ];
        _module.args = { inherit network; };
      })
      {
        router = ./router;
        switch = ./switch;
        ap1 = ./ap/ap1.nix;
        ap2 = ./ap/ap2.nix;
      };
}
