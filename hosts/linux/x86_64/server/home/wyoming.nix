{ ... }: {
  services.wyoming = {
    faster-whisper.servers.default = {
      enable = true;
      uri = "tcp://0.0.0.0:10300";
      # model = "Systran/faster-distil-whisper-small.en";
      language = "en";
      # TODO: get an nvidia gpu?
      # device = "cuda";
    };

    piper.servers.default = {
      enable = true;
      uri = "tcp://0.0.0.0:10200";
      voice = "en_US-amy-medium";
    };

    openwakeword = {
      enable = true;
      preloadModels = [
        # "alexa"
        "oracle"
      ];
      customModelsDirectories = [
        "/etc/wyoming/models"
      ];
      threshold = 0.2;
      # uri = "tcp://0.0.0.0:10400";
    };
  };
}

