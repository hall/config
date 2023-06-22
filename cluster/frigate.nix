{ kubenix, flake, vars, pkgs, ... }:
let
  # https://docs.frigate.video/configuration/index/#full-configuration-reference
  ffmpeg.default_args = "-f segment -segment_time 10 -segment_format mp4 -reset_timestamps 1 -strftime 1 -c copy -an";
in
{
  submodules.instances.frigate = {
    submodule = "release";
    args = {
      image = "ghcr.io/blakeblackshear/frigate:0.12.0";
      port = 5000;
      host = "frigate";
      persistence.media.size = "200Gi";
      values = {
        # required to access coral USB
        securityContext.privileged = true;
        persistence = {
          usb = {
            enabled = true;
            type = "hostPath";
            hostPath = "/dev/bus/usb";
          };
          gpu = {
            enabled = true;
            type = "hostPath";
            hostPath = "/dev/video10";
          };
        };
        nodeSelector = { "${flake.lib.hostname}/tpu" = "true"; };
      };
      config = {
        # ui.use_experimental = true;
        # logger.default = "debug";
        mqtt.host = "mosquitto";
        detectors.coral = {
          type = "edgetpu";
          device = "usb";
        };
        ffmpeg = {
          # https://docs.frigate.video/configuration/hardware_acceleration#raspberry-pi-34-64-bit-os
          hwaccel_args = "preset-rpi-64-h264";
          # https://docs.frigate.video/faqs/#audio-in-recordings
          output_args.record = builtins.replaceStrings [ " -an" ] [ "" ] ffmpeg.default_args;
        };
        record = {
          enabled = true;
          retain = {
            days = 2;
            mode = "motion"; # vs "all"
          };
          events.retain = {
            default = 14;
            mode = "active_objects";
          };
        };
        snapshots.enabled = true;
        # h264 video
        # aac audio
        cameras = {
          front_yard = {
            # prevent detection of globe arbortiae
            # objects.filters.person.max_ratio = 24000000;
            detect = {
              width = 1280;
              height = 720;
            };
            ffmpeg.inputs = [
              {
                path = "rtsp://admin:${vars.secret "/rtsp/front"}@front_yard:554/cam/realmonitor?channel=1&subtype=0";
                roles = [ "record" ];
              }
              {
                path = "rtsp://admin:${vars.secret "/rtsp/front"}@front_yard:554/cam/realmonitor?channel=1&subtype=1";
                roles = [ "rtmp" ];
              }
              {
                path = "rtsp://admin:${vars.secret "/rtsp/front"}@front_yard:554/cam/realmonitor?channel=1&subtype=2";
                roles = [ "detect" ];
              }
            ];
            motion.mask = [
              "123,0,335,0,376,62,138,135" # neighbor's yard
              "990,57,990,0,953,0,938,55" # lamppost across street
            ];
            zones.yard.coordinates = "0,84,0,720,835,720,1256,434,1280,247,743,105,468,66,196,154";
            objects.filters.person.mask = [
              "193,368,565,367,533,93,178,105" # globe arborvitea
            ];
          };
          back_yard = {
            detect = {
              width = 704;
              height = 480;
            };
            ffmpeg.inputs = [
              {
                path = "rtsp://admin:${vars.secret "/rtsp/back"}@back_yard:554/cam/realmonitor?channel=1&subtype=0";
                roles = [ "record" ];
              }
              {
                path = "rtsp://admin:${vars.secret "/rtsp/back"}@back_yard:554/cam/realmonitor?channel=1&subtype=1";
                roles = [ "detect" "rtmp" ];
              }
            ];
            motion.mask = [
              "566,193,704,266,704,0,569,0" # norway spruce
            ];
          };
          doorbell = {
            detect = {
              width = 800;
              height = 480;
            };
            motion.mask = [
              "144,304,162,302,162,275,142,275" # rental mailbox
              "47,293,58,292,60,279,50,277" # neighbor's mailbox
            ];
            ffmpeg = {
              # TODO: add pcm_s16be codec?
              output_args.record = ffmpeg.default_args;
              inputs = [
                {
                  path = "rtsp://admin:${vars.secret "/rtsp/doorbell"}@doorbell:554/cam/realmonitor?channel=1&subtype=1";
                  # 5fps, low res
                  roles = [ "detect" "record" "rtmp" ];
                  # roles = [ "detect" "rtmp" ];
                }
                # {
                #   path = "rtsp://admin:${rtsp.doorbell}@192.168.1.20:554/cam/realmonitor?channel=1&subtype=1";
                #   # 15fps, high res
                #   roles = [ "record" ];
                # }
              ];
            };
          };
        };

      };

    };
  };
}
