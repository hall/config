{ flake }: {
  settings = {
    "org/gnome/settings-daemon/plugins/color" = {
      night-light-enabled = true;
    };
    "org/gnome/settings-daemon/plugins/power" = {
      sleep-inactive-ac-timeout = 2400;
    };
    "org/gnome/mutter/wayland/keybindings" = {
      restore-shortcuts = [ ]; # bound to meta+esc by default which conflicts with stylus tail button
    };
    "org/gnome/desktop/interface" = {
      enable-hot-corners = false;
    };
    "org/gnome/desktop/screensaver" = {
      lock-delay = flake.inputs.home.lib.hm.gvariant.mkUint32 3600;
    };
    "org/gnome/desktop/peripherals/touchpad" = {
      tap-to-click = true;
      speed = 0.5;
      tap-and-drag = false;
    };
    "org/gnome/shell" = {
      disable-user-extensions = false;
    };
    "org/gnome/mutter" = {
      workspaces-only-on-primary = false;
    };
  };
}
