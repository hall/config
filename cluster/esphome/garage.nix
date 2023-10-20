{ ... }: {
  recirculating-pump-power = {
    packages.plug = "!include .plug.yaml";
    substitutions.name = "recirculating-pump-power";
  };
}
