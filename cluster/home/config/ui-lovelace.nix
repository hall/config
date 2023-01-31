{ ... }: {
  title = "Home";
  views = [
    {
      path = "default_view";
      title = "Home";
      badges = [
        {
          entity = "switch.circadian_lighting_circadian_lighting";
          name = "Circadian";
          tap_action.action = "toggle";
          hold_action.action = "more-info";
        }
        { entity = "alarm_control_panel.home"; }
        { entity = "weather.home"; }
      ];
      cards = [{
        type = "custom:floorplan-card";
        config = "/local/floorplan/config.yaml";
        full_height = true;
      }];
    }
  ];
}
