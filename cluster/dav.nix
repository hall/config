{ kubenix, flake, vars, ... }: {
  submodules.instances.dav = {
    submodule = "release";
    args = {
      image = "tomsquest/docker-radicale:3.1.1.0";
      port = 5232;
      host = "dav";
      values = {
        env.RADICALE_CONFIG = "/config/config";
        persistence = {
          data = {
            enabled = true;
            accessMode = "ReadWriteOnce";
            size = "10Gi";
            storageClass = "longhorn-static";
          };
          config = {
            enabled = true;
            type = "configMap";
            # subPath = "config";
            name = "dav-config";
            readOnly = true;
          };
          htpasswd = {
            enabled = true;
            type = "secret";
            subPath = "htpasswd";
            name = "dav-dav";
            readOnly = true;
          };
        };
        secrets.dav = {
          enabled = true;
          stringData.htpasswd = vars.secret "/dav";
        };
        configMaps.config = {
          enabled = true;
          data.config = ''
            [server]
            hosts = 0.0.0.0:5232

            [auth]
            type = htpasswd
            htpasswd_filename = /htpasswd
            htpasswd_encryption = bcrypt

            [storage]
            filesystem_folder = /data/collections
          '';
        };
      };
    };
  };
}
