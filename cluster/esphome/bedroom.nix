{ ... }: {
  nightstand-light-right = {
    packages.rgbww = "!include .rgbww.yaml";
    substitutions = {
      name = "nightstand-light-right";
      id = "nightstand_light_right";
    };
  };
  nightstand-light-left = {
    packages.rgbww = "!include .rgbww.yaml";
    substitutions = {
      name = "nightstand-light-left";
      id = "nightstand_light_left";
    };
  };
}
