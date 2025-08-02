{ pkgs, ... }: {
  services.wyoming = {
    # faster-whisper = {
    #   # package = pkgs.stable.wyoming-faster-whisper;
    #   servers.default = {
    #     enable = true;
    #     uri = "tcp://0.0.0.0:10300";
    #     # model = "Systran/faster-distil-whisper-small.en";
    #     language = "en";
    #     # TODO: get an nvidia gpu?
    #     # device = "cuda";
    #   };
    # };

    # piper.servers.default = {
    #   enable = true;
    #   uri = "tcp://0.0.0.0:10200";
    #   voice = "en_US-amy-medium";
    # };

    # openwakeword = {
    # enable = true;
    # package = pkgs.stable.wyoming-openwakeword;
    # preloadModels = [
    #   "alexa"
    # "oracle"
    #   "ok_nabu"
    # ];
    # customModelsDirectories = [
    #   "/etc/wyoming/models"
    # ];
    # threshold = 0.2;
    # uri = "tcp://0.0.0.0:10400";

    # TODO: wake words
    # bagheera
    # cogsworth
    # lumiere
    # dorian
    # jezebel
    # orion
    # oracle
    # morrigan
    # rafiki
    # };

  };
}

