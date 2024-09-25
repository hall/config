{ config, ... }: {
  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.beta;
    modesetting.enable = true;
    open = true;
    nvidiaSettings = true;
    forceFullCompositionPipeline = true;
    nvidiaPersistenced = true;
    prime = {
      # reduce screen tearing?
      # sync.enable = true;
      # offload.enable = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
    # powerManagement = {
    #   enable = true;
    #   finegrained = true;
    # };
  };

  services.xserver.videoDrivers = [ "nvidia" ];
}
