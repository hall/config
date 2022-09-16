{
  title = "Home";
  views = [
    {
      path = "default_view";
      title = "Home";
      badges = [
        { entity = "person.bryton"; }
        { entity = "person.kristin"; }
        {
          entity = "switch.adaptive_lighting_default";
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
    {

      # - path: printer
      #   title: Printer
      #   cards:
      #     - type: "custom:stack-in-card"
      #       mode: vertical
      #       cards:
      #         - type: picture-glance
      #           camera_image: camera.ender
      #           entities:
      #             - entity: switch.octoprint_connect_to_printer
      #             - entity: script.octoprint_preheat
      #               icon: mdi:thermometer
      #             - entity: script.octoprint_cooldown
      #               icon: mdi:fan
      #               name: Cooldown
      #             - entity: switch.octoprint_cancel_print
      #               name: Cancel
      #             - entity: switch.octoprint_pause_print
      #               name: Pause
      #             - entity: script.print_job_start
      #               icon: mdi:play-box-outline
      #               name: Start
      #             - entity: script.printer_home
      #               icon: mdi:home
      #               tap_action:
      #                 action: toggle

      #         - type: custom:card-templater
      #           card:
      #             type: custom:bar-card
      #             entity: sensor.octoprint_print_progress
      #             name_template: "{{ sensor.octoprint_print_file }}"
      #             positions:
      #               icon: off
      #               name: inside

      #         - type: entities
      #           show_header_toggle: false
      #           entities:
      #             - entity: sensor.octoprint_print_time_left
      #             - entity: sensor.octoprint_print_time

      #         - decimals: 1
      #           entities:
      #             - entity: sensor.octoprint_tool_0_temperature
      #               name: Nozzle
      #               show_state: true
      #             - color: yellow
      #               entity: sensor.octoprint_tool_0_target
      #               name: Nozzle Target
      #               show_legend: false
      #               show_line: false
      #               show_points: false
      #               smoothing: false
      #             - entity: sensor.octoprint_bed_temperature
      #               name: Bed
      #               show_state: true
      #             - color: purple
      #               entity: sensor.octoprint_bed_target
      #               name: Bed Target
      #               show_legend: false
      #               show_line: false
      #               show_points: false
      #               smoothing: false
      #           hours_to_show: 1
      #           points_per_hour: 120
      #           type: "custom:mini-graph-card"
    }
  ];
}
