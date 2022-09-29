{ lib
, buildGoModule
, fetchgit
}:
buildGoModule rec {
  pname = "itd";
  version = "0.0.7";
  src = fetchgit {
    url = "https://gitea.arsenm.dev/Arsen6331/itd";
    rev = "v${version}";
    sha256 = "sha256-pAPNcZLBu3nVYfWAnaECBQcqefduBNL4ot1kquHnLZM=";
  };

  vendorSha256 = "sha256-aYNiwqhla24xTT5YTGbNkUUeOZ6zJ4dpQxpnobQ6AhQ=";

  buildPhase = ''
    make
  '';

  installPhase = ''
    make DESTDIR="$out" PREFIX="" install
  '';

  meta = with lib; {
    description = "InfiniTime daemon";
    homepage = "https://gitea.arsenm.dev/Arsen6331/itd";
    license = licenses.gpl3;
    maintainers = with maintainers; [ ];
    platforms = [ "x86_64-linux" "aarch64-linux" ];
  };
}
