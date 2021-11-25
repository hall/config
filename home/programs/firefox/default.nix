{ pkgs, ... }:
{
  enable = true;
  profiles = {
    default = {
      id = 0;
      name = "default";
      settings = {
        "browser.search.defaultenginename" = "duckduckgo";
        "browser.startup.homepage" = "about:blank";
        "browser.tabs.drawInTitlebar" = false;
        "devtools.theme" = "dark";
        "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
        "projectManager.git.baseFolders" = "~/src";
        "signon.rememberSignons" = false;
        "svg.context-properties.content.enabled" = true;
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
      };
      userChrome = builtins.readFile ./userChrome.css;
      userContent = builtins.readFile ./userContent.css;
    };
  };
  extensions = with pkgs.nur.repos.rycee.firefox-addons; [
    anchors-reveal
    auto-tab-discard
    #buster
    #bypass-paywalls
    darkreader
    i-dont-care-about-cookies
    # gsconnect # TODO: doesn't exist
    # ipfs-companion
    # sidebery # TODO: doesn't exist
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
