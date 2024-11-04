{ buildNpmPackage, fetchFromGitLab, playwright-driver }:
buildNpmPackage rec {
  pname = "gitdock";
  version = "0.1.30";
  src = fetchFromGitLab {
    owner = "mvanremmerden";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-JOyq7dhhCHeCZEPQqTEnW7RWjuLsNuDzWG3TILFZDR4=";
  };
  npmDepsHash = "sha256-PwfFOUxnpAQrljnn+bKMGraDtoyzNlsd/uvWJjveIc4=";
  makeCacheWritable = true;
  # extraBuildInputs = [ chromium ];
  ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
  PLAYWRIGHT_BROWSERS_PATH = playwright-driver.browsers;
  PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS = true;
  postUnpack = ''
    set -x
    npm rm @playwright/test playwright playwright-core
    set +x
  '';
  buildPhase = ''
    npm run package -- --platform:linux
  '';
}
