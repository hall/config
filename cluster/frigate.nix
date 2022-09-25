{ kubenix, flake, vars, pkgs, ... }:
vars.simple {
  inherit kubenix pkgs;
  image = "blakeblackshear/frigate:0.11.0-rc3";
  port = 5000;
  persistence = {
    data.size = "1Gi";
    media.size = "100Gi";
  };
  values = {
    # required to access coral USB
    securityContext.privileged = true;
    persistence.usb = {
      enabled = true;
      type = "hostPath";
      hostPath = "/dev/bus/usb";
    };
    nodeSelector = { "${flake.hostname}/tpu" = "true"; };
  };
  config = {
    # ui.use_experimental = true;
    # logger.default = "debug";
    mqtt.host = "mosquitto.system";
    detectors.coral = {
      type = "edgetpu";
      device = "usb";
    };
    ffmpeg = {
      # https://docs.frigate.video/configuration/hardware_acceleration#raspberry-pi-34-64-bit-os
      hwaccel_args = [ "-c:v" "h264_v4l2m2m" ];
      # https://docs.frigate.video/faqs/#audio-in-recordings
      output_args.record = "-f segment -segment_time 10 -segment_format mp4 -reset_timestamps 1 -strftime 1 -c copy";
    };
    detect = {
      width = 704;
      height = 480;
    };
    record.enabled = true;
    snapshots.enabled = true;
    # h264 video
    # aac audio
    cameras = {
      front_yard.ffmpeg.inputs = [{
        path = ''rtsp://admin:${vars.secret "/rtsp/front"}@front_yard:554/cam/realmonitor?channel=1&subtype=1'';
        roles = [ "detect" "record" "rtmp" ];
      }];
      back_yard.ffmpeg.inputs = [{
        path = ''rtsp://admin:${vars.secret "/rtsp/back"}@back_yard:554/cam/realmonitor?channel=1&subtype=1'';
        roles = [ "detect" "record" "rtmp" ];
      }];
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
          # add pcm_s16be codec
          output_args.record = "-f segment -segment_time 10 -segment_format mp4 -reset_timestamps 1 -strftime 1 -c copy -an";
          inputs = [
            {
              path = ''rtsp://admin:${vars.secret "/rtsp/doorbell"}@192.168.1.20:554/cam/realmonitor?channel=1&subtype=1'';
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
}
