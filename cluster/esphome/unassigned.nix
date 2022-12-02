{ ... }: {
  unassigned-light = {
    packages.rgbww = "!include .rgbww.yaml";
    substitutions = {
      name = "unassigned-light";
      id = "unassigned_light";
    };
  };
}
