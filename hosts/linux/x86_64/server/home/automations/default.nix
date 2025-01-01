{ ... }: {
  services.home-assistant.config.automation = with builtins;
    map (x: import ./${x} { }) (attrNames
      (removeAttrs (readDir ./.) [ "default.nix" ]));
}
