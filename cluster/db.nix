{ kubenix, flake, vars, ... }:
{
  helm.releases.postgresql = {
    chart = kubenix.lib.helm.fetch {
      repo = "https://charts.bitnami.com/bitnami";
      chart = "postgresql";
      version = "11.8.1";
      sha256 = "sha256-dnBdmSqhPqwmetroL93nrY7FPlLfrw3ZddzwPkifBSc=";
    };
    namespace = "system";
    values = {
      image = {
        repository = "postgres";
        tag = "14";
      };
      global.postgresql.auth.postgresPassword = vars.secret "/postgresql/postgres";
      postgresqlDataDir = "/data/pgdata";
      primary.persistence.mountPath = "/data/";
    };
  };
}
