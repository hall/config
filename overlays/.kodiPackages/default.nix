final: prev:
prev.kodiPackages.extend (final': prev': {
  steam-launcher = prev'.steam-launcher.overrideAttrs (old: {
    version = "3.7.11";
    src = final.fetchFromGitHub rec {
      owner = "teeedubb";
      repo = old.owner + "-xbmc-repo";
      rev = "8d0972909c3f1d0cd9e435e77f8b1f59314d52f0";
      sha256 = "";
    };
  });
})
