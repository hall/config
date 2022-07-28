{
  settings = {
    "org/gnome/settings-daemon/plugins/color" = {
      night-light-enabled = true;
    };
    "org/gnome/settings-daemon/plugins/power" = {
      sleep-inactive-ac-timeout = 2400;
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      name = "notes";
      command = "codium notes/dendron.code-workspace --touch-events";
      binding = "<Super>apostrophe";
    };
    "org/gnome/mutter/wayland/keybindings" = {
      restore-shortcuts = [ ]; # bound to meta+esc by default which conflicts with stylus tail button
    };
    "org/gnome/desktop/interface" = {
      enable-hot-corners = false;
      font-name = "Hack Regular";
    };
    "org/gnome/desktop/screensaver" = {
      lock-delay = 3600;
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
