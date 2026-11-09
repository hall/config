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
      options = {
        # anonymous sections are lists, which can't be overridden per key
        system = lib.mkOption {
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
        disabledServices = lib.mkOption {
          type = with lib.types; listOf str;
          default = [ ];
          description = "Init scripts to disable and stop on every deploy.";
        };

        # `--reload` only restarts services that register a config trigger
        restartServices = lib.mkOption {
          type = with lib.types; listOf str;
          default = [ ];
          description = "Init scripts to restart on every deploy, for services that ignore reload_config.";
        };
      };

      config = {
        # by IP: names come from DHCP, so they vanish from DNS while a device reboots
        deploy.host = network.hosts.${name}.ip or network.lan.address;
        # keep using the known_hosts entries recorded under the device name
        deploy.sshConfig = {
          HostKeyAlias = name;
          # a reboot only ends the session if the FIN arrives; when the deployer's
          # own path drops (wifi via the AP being rebooted) ssh would wait forever.
          # 60s rides out roaming to the other AP (same IP) mid-apply, e.g. a wpad swap
          ServerAliveInterval = 5;
          ServerAliveCountMax = 12;
        };

        # secrets are a JSON object encrypted to the same key agenix-rekey uses
        secretsCommand = pkgs.writeShellScript "openwrt-secrets" ''
          ${lib.getExe pkgs.rage} -d -i "$HOME/.ssh/id_ed25519" ${./secrets.json.age}
        '';

        # dewclaw writes with echo, which adds the trailing newline
        etc."dropbear/authorized_keys".text = flake.lib.sshKey;
        users.root.hashedPasswordSecret = "root_pw";

        deploySteps = {
          # dewclaw leaves the (world-readable) hash in /tmp
          rootPassword.apply = lib.mkAfter "rm -f /tmp/root_hash";

          disabledServices = lib.mkIf (config.disabledServices != [ ]) {
            # after uciConfig (90), so nothing later re-enables them
            priority = 95;
            apply = lib.concatMapStrings (svc: ''
              /etc/init.d/${svc} disable
              /etc/init.d/${svc} stop >/dev/null 2>&1 || true
            '') config.disabledServices;
          };

          restartServices = lib.mkIf (config.restartServices != [ ]) {
            # after uciConfig (90), which commits the new config
            priority = 96;
            apply = lib.concatMapStrings (svc: ''
              /etc/init.d/${svc} restart
            '') config.restartServices;
          };
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

          # LuCI, over HTTPS with each device's existing self-signed cert
          uhttpd = {
            uhttpd.main = {
              listen_http = lib.mkDefault [
                "0.0.0.0:80"
                "[::]:80"
              ];
              listen_https = lib.mkDefault [
                "0.0.0.0:443"
                "[::]:443"
              ];
              redirect_https = true;
              home = "/www";
              rfc1918_filter = true;
              max_requests = 3;
              max_connections = 100;
              cert = "/etc/uhttpd.crt";
              key = "/etc/uhttpd.key";
              cgi_prefix = "/cgi-bin";
              lua_prefix = "/cgi-bin/luci=/usr/lib/lua/luci/sgi/uhttpd.lua";
              script_timeout = 60;
              network_timeout = 30;
              http_keepalive = 20;
              tcp_keepalive = true;
              ubus_prefix = "/ubus";
            };
            # only used if the cert above is ever regenerated
            cert.defaults = {
              days = 397;
              key_type = "ec";
              bits = 2048;
              ec_curve = "P-256";
              country = "ZZ";
              state = "Somewhere";
              location = "Unknown";
              commonname = name;
            };
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
