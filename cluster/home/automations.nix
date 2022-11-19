{}: [
  {
    id = "theme_switcher";
    alias = "Set HA theme for day and night";
    trigger = [{
      platform = "homeassistant";
      event = "start";
    }];
    action = [{
      service = "frontend.set_theme";
      data = {
        name = "nord";
        mode = "dark";
      };
    }];
  }

  {
    id = "shellies_announce";
    alias = "Shellies Announce";
    trigger = [
      {
        platform = "homeassistant";
        event = "start";
      }
      {
        platform = "time_pattern";
        hours = "/1"; # Modifying this if you are using Shelly Motion can drain your device's battery quickly.
      }
    ];
    action = {
      service = "mqtt.publish";
      data = {
        topic = "shellies/command";
        payload = "announce";
      };
    };
  }
  {
    id = "shellies_discovery";
    alias = "Shellies Discovery";
    mode = "queued";
    max = 999;
    trigger = {
      platform = "mqtt";
      topic = "shellies/announce";
    };
    action = {
      service = "python_script.shellies_discovery";
      data = {
        id = "{{`{{ trigger.payload_json.id }}`}}";
        mac = "{{`{{ trigger.payload_json.mac }}`}}";
        fw_ver = "{{`{{ trigger.payload_json.fw_ver }}`}}";
        model = "{{`{{ trigger.payload_json.model }}`}}";
        mode = "{{`{{ trigger.payload_json.mode | default }}`}}";
        host = "{{`{{ trigger.payload_json.ip }}`}}";
      };
    };
  }
  {
    id = "motion_detected";
    alias = "Notify of events";
    trigger = {
      platform = "mqtt";
      topic = "frigate/events";
    };
    action = [{
      service = "notify.notify";
      data_template = {
        message = ''A {{`{{ trigger.payload_json["after"]["label"]}}`}} was detected.'';
        data = {
          image = ''https://home.bryton.io/api/frigate/notifications/{{`{{ trigger.payload_json["after"]["id"] }}`}}/thumbnail.jpg?format=android'';
          tag = ''{{`{{ trigger.payload_json["after"]["id"] }}`}}'';
          clickAction = ''https://frigate.bryton.io/events/{{`{{ trigger.payload_json["after"]["id"] }}`}}'';
        };
      };
    }];
  }
  {
    id = "mailbox";
    alias = "you've got mail";
    trigger = [{
      type = "opened";
      platform = "device";
      device_id = "9174005d172e6d03e3a3bbb2c5e42602";
      entity_id = "binary_sensor.shelly_door_window_2_mailbox_opening";
      domain = "binary_sensor";
    }];
    # condition: []
    action = [{
      service = "notify.notify";
      data.message = "mailbox has been opened";
    }];
    mode = "single";
  }
  {
    id = "vacuum";
    alias = "Vacuum (on even days)";
    trigger = {
      platform = "time";
      at = "10:00";
    };
    condition = {
      condition = "template";
      value_template = "{{`{{ now().day % 2 == 0 }}`}}";
    };
    action = {
      service = "vacuum.start";
      data.entity_id = "vacuum.roomba";
    };
  }
]
