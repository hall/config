{ pkgs, flake, flakePkgs, kernel, ... }:
let
  name = "effects";
in
{
  systemd.user.services.${name} = {
    enable = true;
    environment = {
      XDG_RUNTIME_DIR = "/run/user/1000";
      DISPLAY = ":0.0";
    };
    serviceConfig = {
      Type = "forking";
    };
    script = ''
      if ! pgrep ${name}; then
        ${flakePkgs.${name}}/bin/${name} &
      fi

      dev=usb-IK_Multimedia_iRig_HD_2-00
      in=alsa_input.$dev.mono-fallback
      out=alsa_output.$dev.analog-stereo

      sleep 1  # wait for app to register with pw
      ${pkgs.pipewire}/bin/pw-link $in:capture_MONO ${name}:in_0
      ${pkgs.pipewire}/bin/pw-link ${name}:out_0 $out:playback_FL
      ${pkgs.pipewire}/bin/pw-link ${name}:out_0 $out:playback_FR
    '';
  };
  services.udev.extraRules = ''
    # udevadm monitor --environment
    # sudo udevadm info -q all -a $DEVLINKS[0]
    ACTION=="add",\
      KERNEL=="${kernel}",\
      SUBSYSTEM=="sound",\
      ATTRS{interface}=="iRig HD 2",\
      TAG+="systemd"\
      ENV{SYSTEMD_USER_WANTS}="${name}"
  '';
}
