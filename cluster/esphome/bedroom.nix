{ ... }: {
  bedroom-light = {
    packages.rgbww = "!include .rgbww.yaml";
    substitutions = {
      name = "bedroom-light";
      id = "bedroom_light";
    };
  };
}