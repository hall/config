{ flake, config, lib, pkgs, ... }:
let
  hm = config.home-manager.users.${flake.lib.username};
in
{
  config = lib.mkIf config.gui.enable {
    home-manager.users.${flake.lib.username}.wayland.windowManager.sway = {
      enable = true;
      systemd.enable = true;
      extraConfig = ''
        exec systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
      '';
      config = rec {
        modifier = "Mod4"; # GUI key
        bars = [ ]; # replace w/ waybar
        menu = "${pkgs.tofi}/bin/tofi-run | ${pkgs.findutils}/bin/xargs swaymsg exec --";
        window = {
          border = 0;
          titlebar = false;
        };
        floating.titlebar = false;
        keybindings = with pkgs; lib.mkOptionDefault {
          # re-bind to circumvent swaynag
          "${modifier}+Shift+e" = "exec sway exit";
          "${modifier}+p" = "exec ${grim}/bin/grim -g \"$(${slurp}/bin/slurp)\" - | ${satty}/bin/satty --filename - --output-filename ~/Pictures/Screenshots/$(${coreutils}/bin/date +%Y-%m-%d_%H-%M-%S).png";
          "${modifier}+Escape" = "exec ${swaylock}/bin/swaylock -fF";
          "${modifier}+Shift+b" = "exec ${hm.programs.waybar.settings.default.bluetooth.on-click}";

          # media keys (--locked: also work while the screen is locked)
          "--locked XF86MonBrightnessUp" = "exec ${brightnessctl}/bin/brightnessctl set 5%+";
          "--locked XF86MonBrightnessDown" = "exec ${brightnessctl}/bin/brightnessctl set 5%-";
          "--locked XF86AudioMute" = "exec ${wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          "--locked XF86AudioMicMute" = "exec ${wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
          "--locked XF86AudioLowerVolume" = "exec ${wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
          "--locked XF86AudioRaiseVolume" = "exec ${wireplumber}/bin/wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+";
        };
        input = {
          "type:touch".map_to_output = "eDP-1";
          "*" = {
            xkb_layout = "us";
            xkb_variant = "dvorak";

            repeat_rate = "50";
            repeat_delay = "200";

            click_method = "clickfinger";
            natural_scroll = "enabled";

            tap = "enabled";
            drag = "enabled";
            drag_lock = "enabled";
            dwt = "enabled"; # disable while typing
          };
        };
        startup = [
          { command = hm.programs.vscode.package.executableName; }
          { command = "obsidian"; }
          { command = "firefox"; }
        ];
        assigns = {
          "1" = [{ app_id = "obsidian"; }];
          "2" = [{ app_id = "firefox"; }];
          "3" = [{ app_id = hm.programs.vscode.package.executableName; }];
        };
        workspaceOutputAssign = [
          { workspace = "1"; output = "eDP-1"; }
          { workspace = "2"; output = "Dell Inc. DELL S2721NX HLCBZ13"; }
          { workspace = "3"; output = "Dell Inc. DELL S2721NX 9BZZC23"; }
        ];
        output = {
          eDP-1.pos = "0 0";
          "Dell Inc. DELL S2721NX 9BZZC23".pos = "0 -1080";
          "Dell Inc. DELL S2721NX HLCBZ13" = {
            pos = "1920 -1080";
            transform = "90";
          };
        };
      };
    };
  };
}
