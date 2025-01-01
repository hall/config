{}: {
  services.home-assistant.config.automation = with builtins;
    map (x: import ./automations/${x} { })
      (attrNames (readDir ./automations));
}
