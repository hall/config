{ pkgs, ... }:
{
  enable = true;
  profiles = {
    default = {
      id = 0;
      name = "default";
      settings = {
        "browser.aboutConfig.showWarning" = false;
        "browser.newtabpage.enabled" = false;
        "browser.search.defaultenginename" = "duckduckgo";
        "browser.startup.homepage" = "about:blank";
        "browser.display.use_system_colors" = true;
        "browser.startup.page" = 3; # restore previous session
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
    # TODO: don't exist
    # gsconnect
    # sidebery
    # cast-kodi

    # buster
    # bypass-paywalls
    # ipfs-companion
    anchors-reveal
    auto-tab-discard
    bitwarden
    darkreader
    firenvim
    floccus
    https-everywhere
    i-dont-care-about-cookies
    link-cleaner
    multi-account-containers
    refined-github
    temporary-containers
    tridactyl
    ublock-origin
  ];
}
