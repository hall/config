{ buildNpmPackage, fetchFromGitLab }:
buildNpmPackage rec {
  pname = "gitdock";
  version = "0.1.29";
  src = fetchFromGitLab {
    owner = "mvanremmerden";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-Iz4BtoKg3cETzK2Fx77vy9OdLN5wyEtdvUf5E+L3EgI=";
  };
  npmDepsHash = "sha256-6Ff0RKHPiyaoEWQnbyuD5dpH2V6do1JrQ0NwiSQdrJs=";
}
