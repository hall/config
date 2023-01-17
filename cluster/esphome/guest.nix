{ ... }: {
  treadmill-power = {
    packages.plug = "!include .plug.yaml";
    substitutions.name = "treadmill-power";
  };
}
