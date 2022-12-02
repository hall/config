{ ... }: {
  attic-environment = {
    packages.temphumid = "!include .temphumid.yaml";
    substitutions.name = "attic-environment";

    switch = [{
      platform = "gpio";
      id = "chime";
      name = "Doorbell Chime";
      inverted = true;
      pin = "GPIO1";
      icon = "mdi:bell-ring";
      on_turn_on = [
        { delay = "500ms"; }
        { "switch.turn_off" = "chime"; }
      ];
    }];
  };
}
