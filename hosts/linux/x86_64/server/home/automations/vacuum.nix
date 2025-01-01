{ ... }: {
  alias = "vacuum schedule";
  mode = "single";
  triggers = [{
    trigger = "time";
    at = "10:00";
  }];
  conditions = [{
    condition = "time";
    weekday = [ "mon" "thu" ];
  }];
  actions = [{
    action = "vacuum.start";
    target.entity_id = "vacuum.roomba";
  }];
}
