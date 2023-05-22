{ stdenv
, hugo
, fetchFromGitHub
}:
stdenv.mkDerivation rec {
  name = "website";
  src = ./.;

  theme = fetchFromGitHub {
    owner = "luizdepra";
    repo = "hugo-coder";
    rev = "d336b3c"; #"main";
    sha256 = "SPYTWx9H0Y16ZEuoJcHXrq7Owe7QaR4/NmcOKx6kFYk=";
  };

  buildInputs = [
    hugo # for use in a dev shell
  ];

  postUnpack = ''
    mkdir -p ./website/themes
    cp -r ${theme} ./website/themes/${theme.repo}
  '';

  buildPhase = ''
    ${hugo}/bin/hugo
  '';

  installPhase = ''
    cp -r ./public $out
  '';

  meta.platforms = [ "x86_64-linux" "aarch64-linux" ];
}
