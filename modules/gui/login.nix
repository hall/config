{
  flake,
  config,
  lib,
  pkgs,
  ...
}:
let
  # unlock gnome-keyring's login keyring with the LUKS passphrase that
  # systemd-cryptsetup caches in root's kernel keyring (~2.5 min TTL).
  # pam_gnome_keyring can't do this: greetd skips pam_authenticate for
  # default_session, and `gnome-keyring-daemon --unlock` only unlocks a
  # daemon it starts itself, so go through the secret service on D-Bus.
  # requires the login keyring password == LUKS passphrase
  keyring-unlock-dbus =
    pkgs.writers.writePython3 "keyring-unlock-dbus"
      {
        libraries = [ pkgs.python3Packages.jeepney ];
      }
      ''
        import sys
        from jeepney import DBusAddress, new_method_call
        from jeepney.io.blocking import open_dbus_connection
        from jeepney.wrappers import unwrap_msg, DBusErrorResponse

        BUS = "org.freedesktop.secrets"
        ROOT = "/org/freedesktop/secrets"
        LOGIN = ROOT + "/collection/login"
        service = DBusAddress(ROOT, BUS, "org.freedesktop.Secret.Service")
        internal = DBusAddress(
            ROOT, BUS, "org.gnome.keyring.InternalUnsupportedGuiltRiddenInterface"
        )

        # systemd stores every passphrase it was given, NUL-separated
        candidates = [p for p in sys.stdin.buffer.read().split(b"\0") if p]

        conn = open_dbus_connection(bus="SESSION")
        _, session = unwrap_msg(conn.send_and_get_reply(
            new_method_call(service, "OpenSession", "sv", ("plain", ("s", "")))
        ))
        for pw in candidates:
            try:
                unwrap_msg(conn.send_and_get_reply(new_method_call(
                    internal, "UnlockWithMasterPassword", "o(oayays)",
                    (LOGIN, (session, b"", pw, "text/plain")),
                )))
                print("keyring-unlock: login keyring unlocked")
                sys.exit(0)
            except DBusErrorResponse as e:
                err = e
        print(f"keyring-unlock: failed: {err if candidates else 'no passphrase'}")
        sys.exit(1)
      '';

  keyring-unlock = pkgs.writeShellScript "keyring-unlock" ''
    export DBUS_SESSION_BUS_ADDRESS="''${DBUS_SESSION_BUS_ADDRESS:-unix:path=$XDG_RUNTIME_DIR/bus}"
    keyctl=${pkgs.keyutils}/bin/keyctl
    sudo=/run/wrappers/bin/sudo
    if ! id=$($sudo -n $keyctl search @u user cryptsetup 2>/dev/null); then
      echo "keyring-unlock: no cached LUKS passphrase (expired or not set)"
      exit 0
    fi
    $sudo -n $keyctl pipe "$id" | ${keyring-unlock-dbus}
  '';
in
{
  config = lib.mkIf config.gui.enable {
    services = {
      gnome.gnome-keyring.enable = true;
      greetd = {
        enable = true;
        # no login prompt: FDE unlock is the password, so always go
        # straight into sway (also restarts it if sway exits)
        settings.default_session = {
          user = flake.lib.username;
          # unlock the keyring first so apps sway autostarts don't prompt
          command = "${pkgs.bash}/bin/sh -c '${keyring-unlock}; exec ${
            config.home-manager.users.${flake.lib.username}.wayland.windowManager.sway.package
          }/bin/sway'";
        };
      };
    };
  };
}
