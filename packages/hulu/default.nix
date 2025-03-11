{ lib
, pkgs
  # , buildKodiAddon
, fetchFromGitHub
  # , signals
  # , inputstream-adaptive
  # , inputstreamhelper
  # , requests
  # , myconnpy
}:

pkgs.kodiPackages.buildKodiAddon rec {
  pname = "hulu";
  namespace = "plugin.video.hulu";
  version = "0.4.3";

  src = (fetchFromGitHub {
    owner = "matthuisman";
    repo = "slyguy.addons";
    rev = "master";
    hash = "sha256-d4V6TxV4aDtARdrpE8QNWJ6GzlJKVPzURWq0O/sfjGg=";
  }) + /slyguy.hulu;

  skipUnpack = true;

  # propagatedBuildInputs = [
  #   signals
  #   inputstream-adaptive
  #   inputstreamhelper
  #   requests
  #   myconnpy
  # ];

  meta = with lib; {
    homepage = "https://github.com/matthuisman/slyguy.addons/tree/master/slyguy.hulu";
    description = "Hulu Add-on";
    platforms = platforms.all;
    # license = licenses.mit;
    # maintainers = teams.kodi.members ++ [ maintainers.pks ];
  };
}
