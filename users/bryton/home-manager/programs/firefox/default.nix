{ pkgs, ... }:
{
  enable = true;
  profiles = {
    default = {
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
        "print.tab_modal.enabled" = false;
        "geo.enabled" = false;
        "signon.rememberSignons" = false;
        "svg.context-properties.content.enabled" = true;
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
      };
      userChrome = builtins.readFile ./userChrome.css;
      userContent = builtins.readFile ./userContent.css;
    };
  };
  extensions = with pkgs.nur.repos.rycee.firefox-addons; [
    # allow-right-click # TODO
    anchors-reveal
    auto-tab-discard
    bitwarden
    buster-captcha-solver
    bypass-paywalls-clean
    # cast-kodi # TODO
    darkreader
    multi-account-containers
    firefox-translations
    floccus
    # gsconnect # TODO
    https-everywhere
    i-dont-care-about-cookies
    link-cleaner
    sidebery
    temporary-containers
    tridactyl
    ublock-origin
  ];
}
