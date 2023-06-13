{ ... }: {
  submodules.instances.stash = {
    submodule = "release";
    args = {
      image = "stashapp/stash:v0.20.2";
      port = 9999;
      host = "stash";
      persistence = {
        media = {
          size = "50Gi";
          mountPath = "/media";
          accessMode = "ReadWriteMany";
        };
        config = {
          size = "10Gi";
          mountPath = "/root/.stash";
        };
      };
    };
  };
}
