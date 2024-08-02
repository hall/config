{ flake, config, lib }: with lib;
let
  # https://discourse.nixos.org/t/nix-function-to-merge-attributes-records-recursively-and-concatenate-arrays/2030
  recursiveMergeAttrs = fold (attrset: acc: recursiveUpdate attrset acc) { };

  flattenDconf = settings: recursiveMergeAttrs (map
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
with flake.inputs.home.lib.hm.gvariant; {
  settings = flattenDconf {
    # "org/gnome/shell/extensions/blur-my-shell" = {
    #   brightness = 0.75;
    #   noise-amount = 0;
    # };
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
        screensaver.lock-delay = mkUint32 3600;
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
      };
      system.location.enabled = true;
    };
  };
}
