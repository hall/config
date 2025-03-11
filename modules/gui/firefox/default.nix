{ lib, pkgs, ... }: {
  enable = true;
  policies = {
    ExtensionSettings = (builtins.mapAttrs
      (name: value: {
        installation_mode = "force_installed";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/${value}/latest.xpi";
        default_area = "menupanel";
      })
      {
        # about:debugging#/runtime/this-firefox
        "{446900e4-71c2-419f-a6a7-df9c091e268b}" = "bitwarden-password-manager";
        "{278b0ae0-da9d-4cc6-be81-5aa7f3202672}" = "re-enable-right-click";
        "{c607c8df-14a7-4f28-894f-29e8722976af}" = "temporary-containers";
        "{3c078156-979c-498b-8990-85f7987dd929}" = "sidebery";
        "uBlock0@raymondhill.net" = "ublock-origin";
        "addon@darkreader.org" = "darkreader";
        "tridactyl.vim@cmcaine.co.uk" = "tridactyl-vim";
        "@testpilot-containers" = "multi-account-containers";
        "firefox@tampermonkey.net" = "tampermonkey";
        "jid1-KKzOGWgsW3Ao4Q@jetpack" = "i-dont-care-about-cookies";
      });
    # "3rdparty".Extensions = {
    #   "uBlock0@raymondhill.net".adminSettings = { };
    # };
    NoDefaultBookmarks = true;
    PasswordManagerEnabled = false;
    ShowHomeButton = false;
    DisableFirefoxAccounts = true;
    DisableSetDesktopBackground = true;
    DisablePocket = true;
  };
  profiles.default =
    let
      csshacks = pkgs.fetchFromGitHub {
        owner = "MrOtherGuy";
        repo = "firefox-csshacks";
        rev = "master";
        hash = "sha256-eufeXtt/SDcnb+yMMxijRssQr9zeBZQWRLihnxIF49M=";
      };
    in
    {
      userChrome = lib.strings.concatMapStrings builtins.readFile [
        (csshacks + /chrome/autohide_sidebar.css)
        (csshacks + /chrome/urlbar_info_icons_on_hover.css)
        (csshacks + /chrome/page_action_buttons_on_hover.css)
        ./userChrome.css
      ];
      userContent = builtins.readFile ./userContent.css;
      search = {
        default = "DuckDuckGo";
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
      # extensions = with config.nur.repos.rycee.firefox-addons; [
      #   # anchors-reveal
      #   # auto-tab-discard
      #   buster-captcha-solver
      #   # bypass-paywalls-clean
      #   firefox-translations
      #   gsconnect
      #   i-dont-care-about-cookies
      #   link-cleaner
      # ];
      settings = {
        "browser.aboutConfig.showWarning" = false;
        "browser.display.use_system_colors" = true;
        "browser.newtabpage.enabled" = false;
        "browser.search.defaultenginename" = "duckduckgo";
        "browser.startup.homepage" = "about:blank";
        "browser.startup.page" = 3; # restore previous session
        "browser.tabs.drawInTitlebar" = false;
        "browser.tabs.warnOnCloseOtherTabs" = false;
        "browser.toolbars.bookmarks.visibility" = "never";
        # use theme for browser content and toolbar
        "browser.theme.content-theme" = 0;
        "browser.theme.toolbar-theme" = 0;
        "browser.uidensity" = 1; # compact
        "browser.ctrlTab.sortByRecentlyUsed" = false;

        # auto-enable extensions
        "extensions.autoDisableScopes" = 0;
        "extensions.pocket.enabled" = false;

        "geo.enabled" = false;
        "print.tab_modal.enabled" = false;
        "signon.rememberSignons" = false;
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
