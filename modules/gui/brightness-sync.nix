{
  flake,
  config,
  lib,
  pkgs,
  ...
}:
let
  # mirror the internal panel's backlight (as a percentage) onto every
  # external monitor via DDC/CI; re-applies on hotplug so newly
  # connected monitors pick up the current level
  brightness-sync = pkgs.writeShellApplication {
    name = "brightness-sync";
    runtimeInputs = with pkgs; [
      ddcutil
      systemd
      coreutils
      gawk
    ];
    text = ''
      backlight=$(find /sys/class/backlight -mindepth 1 -maxdepth 1 | head -n1)
      [ -n "$backlight" ] || { echo "no backlight device" >&2; exit 1; }

      # bus -> max VCP brightness, bus -> last value written
      declare -A vmax=() last=()

      detect() {
        vmax=() last=()
        local bus m
        while read -r bus; do
          m=$(ddcutil --bus "$bus" getvcp 10 --terse 2>/dev/null | awk '{print $5}') || true
          [ -n "$m" ] && vmax[$bus]=$m
        done < <(ddcutil detect --brief 2>/dev/null | awk '
          /^Display/ { d = 1 } /^Invalid display/ { d = 0 }
          d && /I2C bus:/ { sub(/.*i2c-/, "", $NF); print $NF }')
        echo "external displays (bus:max): $(for b in "''${!vmax[@]}"; do printf '%s:%s ' "$b" "''${vmax[$b]}"; done)"
      }

      sync() {
        local cur max bus v
        cur=$(<"$backlight/brightness")
        max=$(<"$backlight/max_brightness")
        for bus in "''${!vmax[@]}"; do
          v=$(( (cur * vmax[$bus] + max / 2) / max ))
          [ "''${last[$bus]:-}" = "$v" ] && continue
          last[$bus]=$v
          ddcutil --bus "$bus" --noverify setvcp 10 "$v" &
        done
        wait
      }

      # monitors (especially behind a dock) may not answer DDC yet when
      # the session starts, and since they're already attached no
      # hotplug event will follow; keep retrying for a bit
      for _ in $(seq 15); do
        detect
        [ "''${#vmax[@]}" -gt 0 ] && break
        sleep 2
      done
      sync
      while read -r line; do
        hotplug=0
        [[ $line == *"(drm)" ]] && hotplug=1
        # debounce: wait for events (e.g. key repeat) to settle
        while read -r -t 0.3 line; do
          [[ $line == *"(drm)" ]] && hotplug=1
        done
        if [ "$hotplug" = 1 ]; then
          sleep 2 # give newly attached monitors time to answer DDC
          detect
        elif [ "''${#vmax[@]}" -eq 0 ]; then
          detect # nothing known yet; maybe they're answering now
        fi
        sync
      done < <(udevadm monitor --kernel --subsystem-match=backlight --subsystem-match=drm)
    '';
  };
in
{
  config = lib.mkIf config.gui.enable {
    home-manager.users.${flake.lib.username}.systemd.user.services.brightness-sync = {
      Unit = {
        Description = "Sync external monitor brightness to the internal panel";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${brightness-sync}/bin/brightness-sync";
        Restart = "on-failure";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
