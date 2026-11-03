{ pkgs, lib, ... }@args: {
  vscode = import ./vscode.nix args;
  firefox = import ./firefox args;

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
      modules-right = [ "battery" "custom/wlsunset" "bluetooth" "wireplumber" "clock" ];
      # night light: click to start/stop the wlsunset service (stopping
      # it restores normal gamma on all outputs)
      "custom/wlsunset" =
        let
          systemctl = "${pkgs.systemd}/bin/systemctl --user";
        in
        {
          return-type = "json";
          interval = 30;
          signal = 9;
          exec = toString (pkgs.writeShellScript "wlsunset-status" ''
            if ${systemctl} is-active -q wlsunset; then
              printf '{"text":"%s","class":"on","tooltip":"night light: on"}\n' ''
            else
              printf '{"text":"%s","class":"off","tooltip":"night light: off"}\n' ''
            fi
          '');
          on-click = toString (pkgs.writeShellScript "wlsunset-toggle" ''
            if ${systemctl} is-active -q wlsunset; then
              ${systemctl} stop wlsunset
            else
              ${systemctl} start wlsunset
            fi
            ${pkgs.procps}/bin/pkill -RTMIN+9 waybar
          '');
        };
      "sway/window" = {
        max-length = 50;
      };
      # cpu = {
      #   format = "{usage}% ";
      #   tooltip = false;
      # };
      # memory = {
      #   format = "{used:0.1f}G ";
      # };
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
        # toggle earbuds connection (also bound in sway.nix)
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
      #bluetooth.off, #bluetooth.disabled, #custom-wlsunset.off {
        opacity: 0.4;
      }
    '';
  };

  obsidian = {
    enable = true;
    vaults.notes.target = "notes";
  };

  k9s.enable = true;

  foot = {
    enable = true;
    settings.mouse.hide-when-typing = "yes";
  };

}
 