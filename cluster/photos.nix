{ kubenix, vars, ... }:
vars.simple {
  inherit kubenix;
  image = "photoprism/photoprism:220901-bullseye";
  port = 9999;
  persistence = {
    main = {
      size = "30Gi";
      # mountPath = "/photoprism";
      nameOverride = "";
    };
    # config.mountPath = "/config";
  };
  values.env = {
    PHOTOPRISM_PUBLIC = "false";
    PHOTOPRISM_STORAGE_PATH = "/media/storage";
    PHOTOPRISM_ORIGINALS_PATH = "/media/originals";
    PHOTOPRISM_CONFIG_PATH = "/config";
    # PHOTOPRISM_ADMIN_PASSWORD = "please-change";
    # PHOTOPRISM_DATABASE_DRIVER = "mysql";
  };
}
