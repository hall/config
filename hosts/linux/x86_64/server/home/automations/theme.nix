{ ... }: {
  alias = "set default theme";
  trigger = {
    platform = "homeassistant";
    event = "start";
  };
  action = {
    service = "frontend.set_theme";
    data.name = "midnight";
  };
}
