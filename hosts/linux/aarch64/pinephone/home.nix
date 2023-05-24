{ pkgs, flake, ... }: {
  home.packages = with pkgs; [
    # purple-matrix
    # purple-slack
    # tdlib-purple
    pinentry-gnome

    lingot
    itd
    koreader

    chatty
    megapixels
    epiphany
    newsflash

    guitarix
    spot
    drawing
    fragments
    # banking
    tootle
    # waydroid
    pure-maps
    # siglo
    # ardour
    foliate

    usbutils
    libusb1
    # valent

    gnome-podcasts
    gnome-photos
  ] ++ (with pkgs.gnome; [
    geary # email
    totem # videos
    gedit # editor
    nautilus # files
    eog # images
    fractal-next # matrix
    giara # reddit

    gnome-terminal
    # gnome-connections
    gnome-calendar
    gnome-contacts
    gnome-calculator
    gnome-clocks
    #gnome-documents # broken
    gnome-maps
    gnome-music
    gnome-weather
    gnome-system-monitor
    gnome-sound-recorder
    gnome-todo
    gnome-notes
    # gnome-books
    gnome-screenshot
    gnome-dictionary
    gnome-disk-utility
  ]) ++ (with flake.packages; [
    effects
  ]);

  services.gammastep = {
    enable = true;
    # provider = "geoclue";
    latitude = 40.0;
    longitude = -77.0;
  };

  programs = {
    firefox.package = flake.packages.firefox-mobile;
    vscode = {
      userSettings = {
        "editor.folding" = false;
        "editor.minimap.enabled" = false;
        "editor.glyphMargin" = false;
        "git.decorations.enabled" = false;
        "editor.scrollbar.vertical" = "hidden";
        # "workbench.editor.splitInGroupLayout" = "vertical";
        "workbench.editor.openSideBySideDirection" = "down";
      };
      extensions = pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          name = "toggle-zen-mode";
          publisher = "fudd";
          version = "1.1.2";
          sha256 = "sha256-ug1LVun0StMwpWfbtWmkpIVyvTr/ukKwxSEHG+1dFXI=";
        }
      ];
    };
  };

}
 
