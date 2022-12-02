{ ... }: {
  office-environment = {
    packages.temphumid = "!include .temphumid.yaml";
    substitutions.name = "office-environment";
  };
}
