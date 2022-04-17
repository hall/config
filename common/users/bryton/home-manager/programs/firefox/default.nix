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
        "browser.startup.page" = 3; # restore previous session
        "browser.tabs.drawInTitlebar" = false;
        "browser.toolbars.bookmarks.visibility" = "never";
        "devtools.theme" = "dark";
        "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
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
    darkreader
    i-dont-care-about-cookies
    refined-github
    floccus
    link-cleaner
    multi-account-containers
    temporary-containers
    ublock-origin
    bitwarden
    vim-vixen
    https-everywhere
  ];
}
