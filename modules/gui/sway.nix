{ flake, config, lib, pkgs, ... }:
let
  hm = config.home-manager.users.${flake.lib.username};
in
{
  config = lib.mkIf config.gui.enable {
    home-manager.users.${flake.lib.username} = {
      wayland.windowManager.sway = {
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

      programs = {
        swaylock = {
          enable = true;
          settings.no-unlock-indicator = true;
        };

        tofi = {
          enable = true;
          settings = {
            anchor = "top";
            width = "100%";
            height = 30; # config.programs.waybar.settings.default.height;
            horizontal = true;
            # font-size = 14;
            prompt-text = " ";
            outline-width = 0;
            border-width = 0;
            min-input-width = 120;
            result-spacing = 15;
            # padding-top = 0;
            # padding-bottom = 0;
            padding-left = 0;
            padding-right = 0;
          };
        };

        waybar = {
          enable = true;
          systemd.enable = true;
          settings.default = {
            height = 20;
            output = [ "eDP-1" ];
            # layer = "top";
            modules-left = [ "sway/workspaces" "sway/mode" ];
            modules-center = [ "sway/window" ];
            modules-right = [ "battery" "custom/gammastep" "bluetooth" "wireplumber" "clock" ];
            # night light: click to start/stop the gammastep service (stopping
            # it restores normal gamma on all outputs)
            "custom/gammastep" =
              let
                systemctl = "${pkgs.systemd}/bin/systemctl --user";
              in
              {
                return-type = "json";
                interval = 30;
                signal = 9;
                exec = toString (pkgs.writeShellScript "gammastep-status" ''
                  if ${systemctl} is-active -q gammastep; then
                    printf '{"text":"%s","class":"on","tooltip":"night light: on"}\n' ''
                  else
                    printf '{"text":"%s","class":"off","tooltip":"night light: off"}\n' ''
                  fi
                '');
                on-click = toString (pkgs.writeShellScript "gammastep-toggle" ''
                  if ${systemctl} is-active -q gammastep; then
                    ${systemctl} stop gammastep
                  else
                    ${systemctl} start gammastep
                  fi
                  ${pkgs.procps}/bin/pkill -RTMIN+9 waybar
                '');
              };
            "sway/window" = {
              max-length = 50;
            };
            battery = {
              format = "{icon}";
              format-icons = [ "" "" "" "" "" ];
            };
            clock = {
              format-alt = "{:%a, %d. %b  %H:%M}";
            };
            bluetooth = {
              format = "";
              format-connected = "";
              format-off = "";
              format-disabled = "";
              tooltip-format-connected = "{device_enumerate}";
              tooltip-format-enumerate-connected = "{device_alias}";
              # toggle earbuds connection (also bound to a sway key above)
              on-click = toString (pkgs.writeShellScript "buds-toggle" ''
                mac=AC:3E:B1:84:FB:A7
                bt=${pkgs.bluez}/bin/bluetoothctl
                if $bt info $mac | grep -q "Connected: yes"; then
                  $bt disconnect $mac
                else
                  $bt power on && $bt connect $mac
                fi
              '');
            };
            wireplumber = {
              format = "{icon}";
              format-muted = "";
              on-click = "helvum";
              format-icons = [ "" "" "" ];
            };
          };
          style = ''
            * {
              font-size: 12px;
              min-height: 0;
            }
            #bluetooth.off, #bluetooth.disabled, #custom-gammastep.off {
              opacity: 0.4;
            }
          '';
        };
      };

      # waybar's wireplumber module doesn't reconnect if pipewire restarts
      # (e.g. on switch), leaving the volume indicator stale; restart with it
      systemd.user.services.waybar.Unit = {
        PartOf = [ "pipewire.service" ];
        After = [ "pipewire.service" ];
      };

      services.swayidle = {
        # enable = true;
        events = [
          { event = "before-sleep"; command = "${pkgs.swaylock}/bin/swaylock -fF"; }
          { event = "lock"; command = "lock"; }
        ];
        timeouts = [
          { timeout = 600; command = "${pkgs.swaylock}/bin/swaylock -fF"; }
          { timeout = 900; command = "${pkgs.systemd}/bin/systemctl suspend"; }
        ];
      };
    };
  };
}
