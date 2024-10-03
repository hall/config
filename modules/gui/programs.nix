{ pkgs, ... }: {
  vscode = import ./vscode.nix pkgs;
  firefox = import ./firefox pkgs;

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
    settings.default = {
      height = 20;
      output = [ "eDP-1" ];
      # layer = "top";
      modules-left = [ "sway/workspaces" "sway/mode" ];
      modules-center = [ "sway/window" ];
      modules-right = [ "battery" "wireplumber" "clock" ];
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
    '';
  };

  k9s.enable = true;

  foot = {
    enable = true;
    settings.mouse.hide-when-typing = "yes";
  };

}
 