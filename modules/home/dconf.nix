{ flake, config, lib }: with lib;
with flake.inputs.home.lib.hm.gvariant;
let
  flattenDconf = settings: flake.lib.recursiveMergeAttrs (map
    (x: { "${x.name}" = x.value; })
    (collect (x: x ? name && x ? value)
      (mapAttrsRecursive
        (path: value: nameValuePair
          (concatStringsSep "/" (lists.init path))
          { "${lists.last path}" = value; }
        )
        settings)
    )
  );
in
{
  settings = flattenDconf {
    # "org/gnome/shell/extensions/blur-my-shell" = {
    #   brightness = 0.75;
    #   noise-amount = 0;
    # };
    # "org/gnome/desktop/screensaver" = {
    # lock-delay = mkUint32 3600;
    # };
    ca.desrt.dconf-editor.show-warning = false;
    org.gnome = {
      settings-daemon.plugins = {
        color.night-light-enabled = true;
        power.sleep-inactive-ac-timeout = 2400;
      };
      mutter = {
        # bound to meta+esc by default which conflicts with stylus tail button
        wayland.keybindings.restore-shortcuts = [ ];
        workspaces-only-on-primary = false;
      };
      desktop = {
        interface.enable-hot-corners = false;
        screensaver.lock-delay = 3600;
        peripherals.touchpad = {
          tap-to-click = true;
          speed = 0.5;
          tap-and-drag = false;
        };
      };
      shell = {
        disable-user-extensions = false;
        enabled-extensions = lib.lists.forEach
          (builtins.filter (pkg: pkg ? extensionUuid)
            config.home-manager.users.${flake.lib.username}.home.packages)
          (pkg: pkg.extensionUuid);
        favorite-apps = [ "firefox.desktop" "logseq.desktop" "code.desktop" ];
      };
      system.location.enabled = true;
    };
  };
}
