{ pkgs, flake, lib, ... }:
let
  kodi = pkgs.kodi.withPackages (p: with p; [
    jellyfin
    inputstream-adaptive
    netflix
    # crunchyroll
    # youtube
    # steam-library # or steam-launcher?
    # steam-controller # ? or joystick
    # sendtokodi
    # libretro # and friends
  ]);
in
{
  boot.kernelParams = [
    "video=DP-2:1920x1080@60"
    # "drm.edid_firmware=DP-2:edid/edid.bin"  # Temporarily disabled
    # "drm.edid_firmware=DP-2:disable" # Force disable EDID override
    # "intel_iommu=off"  # Temporarily removed - may affect audio routing
    "i915.force_probe=*"
    "drm.debug=0x1f" # Enable debug logging
    "log_level=3"
    # Intel HDMI audio fixes - RELIABLE HDMI
    "snd_hda_intel.power_save=0"
    # "snd_hda_intel.probe_mask=3"  # Temporarily removed - assumes codec exists
    "snd_hda_intel.jackpoll_ms=5000"
    "snd_hda_intel.debug=1" # Enable audio debug logging
    # Force HDMI presence detection on actual connected port
    "drm_kms_helper.edid_firmware=DP-2:force"
  ];

  # hardware.display.edid.packages = [
  #   (pkgs.runCommand "edid-custom" { } ''
  #     mkdir -p "$out/lib/firmware/edid"
  #     base64 -d > "$out/lib/firmware/edid/edid.bin" <<-EOF
  #     AP///////wBMLRdwAA4AAQEeAQOApV14Cqgzq1BFpScNSEi974BxT4HAgQCBgJUAqcCzANHACOgAMPJwWoCwWIoAUB10AAAeVl4AoKCgKVAwIDUAUB10AAAaAAAA/ABTQU1TVU5HCiAgICAgAAAA/QAYSw+HPAAKICAgICAgASACAzvxUpAfBBMFFCAhIl1eX2JkBxYDEikJBwcVB1A9B8CDAQAAbgMMACEAgB4oAIABAgME4wXDAeIATwI6gBhxOC1AWCxFAFAddAAAHgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAeA==
  #     EOF
  #   '')
  # ];


  environment.systemPackages = with pkgs; [
    xorg.xrandr # kodi uses
    steam
    libcec
    alsa-utils
    alsa-tools
    ncpamixer
    gd
    pulseaudio
    pavucontrol
    edid-decode
  ] ++ [ kodi ];

  # environment.etc."wireplumber/policy/51-hdmi-default.conf".text = ''
  #   {
  #     "rules": [
  #       {
  #         "matches": [
  #           {
  #             "node.name": "matches:alsa_output.*HDMI*"
  #           }
  #         ],
  #         "actions": {
  #           "update-props": {
  #             "priority.session": 100,
  #             "priority.driver": 100,
  #             "node.autoconnect": true,
  #             "node.disabled": false,
  #             "node.description": "HDMI Output"
  #           }
  #         }
  #       }
  #     ]
  #   }
  # '';

  environment.etc."X11/xorg.conf.d/10-disable.conf".text = ''
    Section "Monitor"
        Identifier "DP-1"
        Option "Ignore" "true"
    EndSection

    Section "Monitor"
        Identifier "DP-2"
        Option "Primary" "true"
        Option "PreferredMode" "1920x1080"
    EndSection

    Section "Monitor"
        Identifier "DP-3"
        Option "Ignore" "true"
    EndSection

    Section "Monitor"
        Identifier "DP-4"
        Option "Ignore" "true"
    EndSection

    Section "Monitor"
        Identifier "HDMI-1"
        Option "Ignore" "true"
    EndSection
  '';


  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    wireplumber.enable = true;
    wireplumber.extraConfig = {
      av = {
        "session.suspend-timeout-seconds" = 0;
        "node.pause-on-idle" = false;
        "session.suspend-on-idle" = false;
      };
      # Ensure HDMI audio devices are available
      "hdmi-audio" = {
        "monitor.alsa.rules" = [
          {
            "matches" = [
              { "device.name" = "~alsa_card.pci-0000_00_1f.3"; }
            ];
            "actions" = {
              "update-props" = {
                "device.disabled" = false;
                "alsa.use-acp" = false;
              };
            };
          }
        ];
      };
    };
  };

  users.users.${flake.lib.username}.linger = true;

  networking.firewall = {
    allowedTCPPorts = [
      8080 # Kodi web server/JSON-RPC
      8081
      9090
    ];
    allowedUDPPorts = [ 9777 ];
  };


  services.upower.enable = true;

  # HDMI AUDIO DETECTION AND ACTIVATION SERVICE
  systemd.services.hdmi-audio-setup = {
    description = "HDMI Audio Detection and Setup";
    wants = [ "sound.target" ];
    wantedBy = [ "multi-user.target" ];
    after = [ "sound.target" "display-manager.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "hdmi-audio-setup" ''
        # Wait for audio and display system initialization
        sleep 10

        echo "=== HDMI Audio Detection ==="

        # Check available audio devices
        echo "Available audio devices:"
        ${pkgs.alsa-utils}/bin/aplay -l || true

        # Check if HDMI codec exists
        if [ -e "/dev/snd/hwC0D2" ]; then
          echo "✓ HDMI codec detected at /dev/snd/hwC0D2"
        else
          echo "✗ HDMI codec not detected"
          exit 1
        fi

        # Configure digital audio controls
        echo "Configuring digital audio controls..."
        ${pkgs.alsa-utils}/bin/amixer -c 0 sset Master 80% unmute || true

        # Enable all available IEC958 (digital) controls
        for i in 0 1 2 3; do
          if ${pkgs.alsa-utils}/bin/amixer -c 0 scontrols | grep -q "IEC958.*,$i"; then
            echo "Enabling IEC958,$i..."
            ${pkgs.alsa-utils}/bin/amixer -c 0 sset "IEC958,$i" on || true
          fi
        done

        # Skip audio test during boot (may conflict with Kodi startup)
        echo "HDMI audio configuration complete (skipping test during boot)"

        echo "=== HDMI Audio Setup Complete ==="
      '';
    };
  };

  # Add a manual HDMI audio test service for debugging
  systemd.services.hdmi-audio-test = {
    description = "Manual HDMI Audio Test";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "hdmi-audio-test" ''
        echo "=== Manual HDMI Audio Test ==="
        
        # Stop any processes that might be using audio
        ${pkgs.procps}/bin/pkill -f kodi || true
        sleep 2
        
        # Test HDMI audio
        if timeout 5 ${pkgs.alsa-utils}/bin/speaker-test -c 2 -t wav -D hw:0,3 -l 2 2>/dev/null; then
          echo "✓ HDMI audio test successful"
        else
          echo "✗ HDMI audio test failed"
          exit 1
        fi
      '';
    };
  };

  # Periodic HDMI audio keepalive service - TEMPORARILY DISABLED FOR DEBUGGING
  # systemd.services.hdmi-audio-keepalive = {
  #   description = "HDMI Audio Keepalive";
  #   serviceConfig = {
  #     Type = "oneshot";
  #     ExecStart = pkgs.writeShellScript "hdmi-keepalive" ''
  #       # Check if HDMI codec exists first
  #       if [ -e "/dev/snd/hwC0D2" ]; then
  #         # Check if HDMI pin is still enabled
  #         PIN_STATUS=$(${pkgs.alsa-tools}/bin/hda-verb /dev/snd/hwC0D2 0x06 0xf07 0x00 2>/dev/null | grep -o "0x[0-9a-f]*" | tail -1 || echo "0x00")
  #         
  #         if [[ "$PIN_STATUS" != "0x40" ]]; then
  #           echo "HDMI pin disabled, re-enabling..."
  #           ${pkgs.alsa-tools}/bin/hda-verb /dev/snd/hwC0D2 0x06 0x707 0x40 2>/dev/null || true
  #           ${pkgs.alsa-tools}/bin/hda-verb /dev/snd/hwC0D2 0x06 0x3b0 0x00 2>/dev/null || true
  #         fi
  #       else
  #         echo "HDMI codec not found at /dev/snd/hwC0D2 - audio hardware may not be properly detected"
  #       fi
  #       
  #       # Check if IEC958 control exists before trying to use it
  #       if ${pkgs.alsa-utils}/bin/amixer -c 0 scontrols | grep -q "IEC958"; then
  #         ${pkgs.alsa-utils}/bin/amixer -c 0 sget IEC958 | grep -q "off" && {
  #           ${pkgs.alsa-utils}/bin/amixer -c 0 sset IEC958 on
  #         } || true
  #       else
  #         echo "IEC958 control not available - HDMI audio may not be properly configured"
  #       fi
  #     '';
  #   };
  # };

  # systemd.timers.hdmi-audio-keepalive = {
  #   description = "HDMI Audio Keepalive Timer";
  #   wantedBy = [ "timers.target" ];
  #   timerConfig = {
  #     OnBootSec = "2min";
  #     OnUnitActiveSec = "30s";
  #   };
  # };

  hardware.bluetooth.enable = true;

  services = {
    displayManager.autoLogin = {
      enable = true;
      user = flake.lib.username;
    };
    xserver = {
      enable = true;
      windowManager.openbox.enable = true;
      displayManager.lightdm.enable = true;
      # videoDrivers = [ "intel" "modesetting" ];
    };
  };

  services.logind.settings.Login = {
    HandleSuspendKey = "ignore";
    HandleLidSwitch = "ignore";
    HandleHibernateKey = "ignore";
  };


  home-manager.users.${flake.lib.username} = {
    # programs.kodi = {
    #   enable = true;
    #   package = kodi;
    # };

    xdg.configFile."openbox/autostart".text = ''
      xset -dpms
      xset s off
      xset s noblank
      sleep 5
      ${kodi}/bin/kodi --fullscreen &
    '';

    home.file.".kodi/userdata/peripheral_data/usb_2548_1002_CEC_Adapter.xml" = {
      force = true;
      text = ''
        <settings>
          <setting id="enabled" value="1"/>
          <setting id="activate_source" value="0"/>
          <setting id="cec_hdmi_port" value="1"/>
          <setting id="standby_tv_on_pc_standby" value="0"/>
          <setting id="send_inactive_source" value="1"/>
          <setting id="device_name" value="Kodi"/>
          <setting id="device_type" value="36048"/>
          <setting id="physical_address" value="0"/>
          <setting id="connected_device" value="36038"/>
          <setting id="wake_devices" value="36038"/>
          <setting id="standby_devices" value="36036"/>
          <setting id="cec_standby_screensaver" value="0"/>
          <setting id="cec_wake_screensaver" value="0"/>
          <setting id="pause_or_stop_playback_on_deactivate" value="36045"/>
          <setting id="button_release_delay_ms" value="0"/>
          <setting id="button_repeat_rate_ms" value="0"/>
          <setting id="double_tap_timeout_ms" value="300"/>
          <setting id="use_tv_menu_language" value="1"/>
          <setting id="tv_vendor" value="0"/>
          <setting id="power_avr_on_as" value="1"/>
        </settings>
      '';
    };
  };

}
