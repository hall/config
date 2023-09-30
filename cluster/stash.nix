{ ... }: {
  submodules.instances.stash = {
    submodule = "release";
    args = {
      image = "stashapp/stash:v0.22.1";
      port = 9999;
      host = "stash";
      persistence = {
        media = {
          size = "500Gi";
          mountPath = "/media";
          accessMode = "ReadWriteMany";
        };
        config = {
          size = "100Gi";
          mountPath = "/root/.stash";
        };
      };
    };
  };
}
