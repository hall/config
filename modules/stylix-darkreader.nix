{ config, lib, ... }: {
  options.stylix.targets.darkreader = {
    enable = config.lib.stylix.mkEnableTarget "darkreader" true;
  };

  config = lib.mkIf (config.stylix.enable && config.stylix.targets.darkreader.enable) {
    # TODO: must be manually imported through the extension settings
    home.xdg.configFile.darkreader = {
      enable = true;
      #onChange = manually tell darkreader to refresh somehow?
      target = "darkreader/config.json";
      text = builtins.toJSON {
        schemeVersion = 2;
        enabled = true;
        fetchNews = true;
        theme = with config.lib.stylix.colors; {
          mode = 1;
          brightness = 100;
          contrast = 100;
          grayscale = 0;
          sepia = 0;
          useFont = false;
          fontFamily = "Open Sans";
          textStroke = 0;
          engine = "dynamicTheme";
          stylesheet = "";
          darkSchemeBackgroundColor = "#${base00}";
          darkSchemeTextColor = "#${base05}";
          lightSchemeBackgroundColor = "#${base05}";
          lightSchemeTextColor = "#${base00}";
          scrollbarColor = "auto";
          selectionColor = "auto";
          styleSystemControls = false;
          lightColorScheme = "Default";
          darkColorScheme = "Default";
          immediateModify = false;
        };
        presets = [ ];
        customThemes = [ ];
        enabledByDefault = true;
        enabledFor = [ ];
        disabledFor = [ ];
        changeBrowserTheme = false;
        syncSettings = false;
        syncSitesFixes = true;
        automation = {
          enabled = false;
          mode = "system";
          behavior = "OnOff";
        };
        time = {
          activation = "18:00";
          deactivation = "9:00";
        };
        location = {
          latitude = null;
          longitude = null;
        };
        previewNewDesign = true;
        previewNewestDesign = true;
        enableForPDF = true;
        enableForProtectedPages = true;
        enableContextMenus = false;
        detectDarkTheme = false;
        displayedNews = [
          "thanks-2023"
        ];
      };
    };
  };
}
