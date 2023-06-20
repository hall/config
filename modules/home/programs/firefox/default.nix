{ pkgs, ... }: {
  enable = true;
  package = with pkgs; wrapFirefox firefox-unwrapped {
    cfg = {
      enableGnomeExtensions = true;
      enableTridactylNative = true;
    };
    extraPolicies.ExtensionSettings = (builtins.mapAttrs
      (name: value: {
        installation_mode = "force_installed";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/${value}/latest.xpi";
      })
      {
        "{446900e4-71c2-419f-a6a7-df9c091e268b}" = "bitwarden-password-manager";
        "{278b0ae0-da9d-4cc6-be81-5aa7f3202672}" = "re-enable-right-click";
        "{c607c8df-14a7-4f28-894f-29e8722976af}" = "temporary-containers";
        "uBlock0@raymondhill.net" = "ublock-origin";
        "addon@darkreader.org" = "darkreader";
        "tridactyl.vim@cmcaine.co.uk" = "tridactyl-vim";
        "@testpilot-containers" = "multi-account-containers";
      }) // {
      "{3c078156-979c-498b-8990-85f7987dd929}" = {
        installation_mode = "forced_installed";
        # need beta for search bar
        install_url = "https://github.com/mbnuqw/sidebery/releases/download/v5.0.0b31/sidebery-5.0.0b31.xpi";
      };
    };
    # "Containers": {
    #   "Default": [
    #     {
    #       "name": "My container",
    #       "icon": "pet",
    #       "color": "turquoise"
    #     }
    #   ]
    # }
  };
  profiles.default = {
    userChrome = builtins.readFile ./userChrome.css;
    userContent = builtins.readFile ./userContent.css;
    search = {
      default = "DuckDuckGo";
      force = true; # prevent ff from overwriting
    };
    # extensions = with pkgs.nur.repos.rycee.firefox-addons; [
    #   # anchors-reveal
    #   # auto-tab-discard
    #   buster-captcha-solver
    #   # bypass-paywalls-clean
    #   # cast-kodi # TODO
    #   firefox-translations
    #   floccus
    #   gsconnect
    #   i-dont-care-about-cookies
    #   link-cleaner
    # ];
    settings = {
      "browser.aboutConfig.showWarning" = false;
      "browser.newtabpage.enabled" = false;
      "browser.search.defaultenginename" = "duckduckgo";
      "browser.startup.homepage" = "about:blank";
      "browser.display.use_system_colors" = true;
      # restore previous session
      "browser.startup.page" = 3;
      "browser.tabs.drawInTitlebar" = false;
      "browser.toolbars.bookmarks.visibility" = "never";
      "browser.uidensity" = 1; # compact
      "print.tab_modal.enabled" = false;
      "geo.enabled" = false;
      "signon.rememberSignons" = false;
      "svg.context-properties.content.enabled" = true;
      "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
      # do not allow websites to steal keyboard input
      "permissions.default.shortcuts" = 2;
      "extensions.pocket.enabled" = false;
      # customize the toolbar
      # TODO: can this be cleaned up?
      # "browser.uiCustomization.state" = {
      #   placements = {
      #     widget-overflow-fixed-list = [ ];
      #     unified-extensions-area = [
      #       "_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action" # bitwarden
      #       "ublock0_raymondhill_net-browser-action"
      #       "_3c078156-979c-498b-8990-85f7987dd929_-browser-action" # sidebery
      #       "_278b0ae0-da9d-4cc6-be81-5aa7f3202672_-browser-action" # allow-right-click
      #       "addon_darkreader_org-browser-action"
      #       "_testpilot-containers-browser-action"
      #     ];
      #     nav-bar = [
      #       "back-button"
      #       "forward-button"
      #       "stop-reload-button"
      #       "urlbar-container"
      #       "downloads-button"
      #       "unified-extensions-button"
      #       "fxa-toolbar-menu-button"
      #     ];
      #     toolbar-menubar = [ "menubar-items" ];
      #     TabsToolbar = [
      #       "firefox-view-button"
      #       "tabbrowser-tabs"
      #       "new-tab-button"
      #       "alltabs-button"
      #       "_c607c8df-14a7-4f28-894f-29e8722976af_-browser-action"
      #     ];
      #     PersonalToolbar = [ "import-button" "personal-bookmarks" ];
      #   };
      #   seen = [
      #     "developer-button"
      #     "_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action"
      #     "ublock0_raymondhill_net-browser-action"
      #     "_3c078156-979c-498b-8990-85f7987dd929_-browser-action"
      #     "_278b0ae0-da9d-4cc6-be81-5aa7f3202672_-browser-action"
      #     "addon_darkreader_org-browser-action"
      #     "_c607c8df-14a7-4f28-894f-29e8722976af_-browser-action"
      #     "_testpilot-containers-browser-action"
      #   ];
      #   dirtyAreaCache = [
      #     "nav-bar"
      #     "unified-extensions-area"
      #     "PersonalToolbar"
      #     "toolbar-menubar"
      #     "TabsToolbar"
      #   ];
      #   currentVersion = 19;
      #   newElementCount = 2;
      # };
    };
  };
}
