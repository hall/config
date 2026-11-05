{
  config,
  lib,
  pkgs,
  ...
}:
{
  enable = true;
  policies = {
    DefaultSerialGuardSetting = 3; # allow webserial for midi.academy
    ExtensionSettings = {
      # block (and uninstall) anything not explicitly listed
      "*".installation_mode = "blocked";
      # installed by stylix (targets.firefox.colorTheme)
      "FirefoxColor@mozilla.com".installation_mode = "allowed";
    }
    # nur packages are only used for their addon ids;
    # the xpi itself is always the latest from AMO
    // lib.listToAttrs (
      map
        (
          p:
          lib.nameValuePair p.addonId {
            installation_mode = "force_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/${p.addonId}/latest.xpi";
            default_area = "menupanel";
          }
        )
        (
          with pkgs.nur.repos.rycee.firefox-addons;
          [
            bitwarden
            darkreader
            multi-account-containers
            temporary-containers
            tridactyl
            ublock-origin
          ]
          ++ config.gui.firefoxExtensions
        )
    );
    NoDefaultBookmarks = true;
    PasswordManagerEnabled = false;
    ShowHomeButton = false;
    #DisableFirefoxAccounts = true;
    DisableSetDesktopBackground = true;
    DisableTelemetry = true;
    DisableFirefoxStudies = true;
    DontCheckDefaultBrowser = true;
    UserMessaging = {
      ExtensionRecommendations = false;
      FeatureRecommendations = false;
      MoreFromMozilla = false;
      SkipOnboarding = true;
      Locked = true;
    };
  };
  profiles.default =
    let
      csshacks = pkgs.fetchFromGitHub {
        owner = "MrOtherGuy";
        repo = "firefox-csshacks";
        # pin to a commit, not "master" — a branch ref silently moves and
        # breaks this fixed-output derivation's hash on every upstream push
        rev = "4869329f67522f17cd86bf504a552089d07261d5";
        hash = "sha256-iIuUfNjQ6miVHrKm3ZBafCRNXEVnHDu0QSiR81PwLdE=";
      };
    in
    {
      userChrome = lib.strings.concatMapStrings builtins.readFile [
        (csshacks + /chrome/urlbar_info_icons_on_hover.css)
        (csshacks + /chrome/page_action_buttons_on_hover.css)
        ./userChrome.css
      ];
      # userContent = builtins.readFile ./userContent.css;
      # let stylix's colorTheme overwrite firefox-color's stored theme
      extensions.settings."FirefoxColor@mozilla.com".force = true;
      search = {
        default = "ddg";
        force = true; # prevent ff from overwriting
      };
      containersForce = true;
      containers = {
        github = {
          id = 1;
          name = "github";
          color = "blue";
          icon = "circle";
        };
        google = {
          id = 2;
          name = "google";
          color = "blue";
          icon = "circle";
        };
        work = {
          id = 3;
          name = "work";
          color = "green";
          icon = "circle";
        };
        amazon = {
          id = 4;
          name = "amazon";
          color = "orange";
          icon = "circle";
        };
      };
      settings = {
        "browser.aboutConfig.showWarning" = false;
        "browser.display.use_system_colors" = true;
        "browser.newtabpage.enabled" = false;
        "browser.ml.chat.enabled" = false;
        "browser.startup.homepage" = "about:blank";
        "browser.startup.page" = 3; # restore previous session
        "browser.tabs.warnOnCloseOtherTabs" = false;
        "browser.toolbars.bookmarks.visibility" = "never";
        # use theme for browser content and toolbar
        "browser.theme.content-theme" = 0;
        "browser.theme.toolbar-theme" = 0;
        "browser.uidensity" = 1; # compact
        "browser.ctrlTab.sortByRecentlyUsed" = false;

        # native vertical tabs in an auto-hiding sidebar
        # (both require the revamped sidebar)
        "sidebar.revamp" = true;
        "sidebar.verticalTabs" = true;
        "sidebar.visibility" = "expand-on-hover";

        # auto-enable extensions
        "extensions.autoDisableScopes" = 0;

        "geo.enabled" = false;

        # Camera and microphone permissions
        "media.webrtc.camera.allow-pipewire" = true;
        "print.tab_modal.enabled" = false;
        "svg.context-properties.content.enabled" = true;
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

        # don't allow sites to steal keyboard input
        # TODO: breaks tridactyl `esc` :/
        # "permissions.default.shortcuts" = 2;

        # https://bugzilla.mozilla.org/show_bug.cgi?id=1818517#c1
        "widget.gtk.ignore-bogus-leave-notify" = 1;
      };
    };
}
