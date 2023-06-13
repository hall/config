{ kubenix, flake, vars, ... }:
{
  kubernetes.helm.releases.postgresql = {
    chart = kubenix.lib.helm.fetch {
      repo = "https://charts.bitnami.com/bitnami";
      chart = "postgresql";
      version = "11.8.1";
      sha256 = "sha256-dnBdmSqhPqwmetroL93nrY7FPlLfrw3ZddzwPkifBSc=";
    };
    values = {
      image = {
        repository = "postgres";
        tag = "14";
      };
      auth.postgresPassword = vars.secret "/postgresql/postgres";
      postgresqlDataDir = "/data/pgdata";
      primary.persistence.mountPath = "/data/";
    };
  };
}
