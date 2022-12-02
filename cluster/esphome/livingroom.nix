{ ... }: {
  livingroom-light = {
    packages.rgbww = "!include .rgbww.yaml";
    substitutions = {
      name = "livingroom-light";
      id = "livingroom_light";
    };
  };
}
