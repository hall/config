# Raspberry Pi 4
# WAN: USB Ethernet (wan0) - DHCP from ISP
# LAN: Built-in Ethernet (lan0) - 192.168.1.1/24
{ pkgs, config, ... }: {
  imports = [
    ./hardware.nix
    ./networking.nix
  ];

  boot = {
    kernelModules = [ "nf_nat" "nf_conntrack" ];
    kernel.sysctl = {
      # Enable IP forwarding
      "net.ipv4.ip_forward" = 1;
      "net.ipv6.conf.all.forwarding" = 1;

      # Increase connection tracking table size
      "net.netfilter.nf_conntrack_max" = 65536;

      # Optimize network performance
      "net.core.netdev_max_backlog" = 5000;
      "net.ipv4.tcp_congestion_control" = "bbr";

      # Security hardening
      "net.ipv4.conf.all.rp_filter" = 1;
      "net.ipv4.conf.default.rp_filter" = 1;
      "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
      "net.ipv4.conf.all.accept_source_route" = 0;
      "net.ipv6.conf.all.accept_source_route" = 0;
      "net.ipv4.conf.all.send_redirects" = 0;
      "net.ipv4.conf.default.send_redirects" = 0;
    };
  };

  # Optimize for headless router
  systemd = {
    targets = {
      sleep.enable = false;
      suspend.enable = false;
      hibernate.enable = false;
      hybrid-sleep.enable = false;
    };
    services = {
      "getty@tty1".enable = false;
      "autovt@tty1".enable = false;
    };
  };

  environment.systemPackages = with pkgs; [
    ethtool
    iperf3
    tcpdump
    conntrack-tools
  ];

  age.rekey.hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH6DSDGDvYlysCDsQ6mSBTXclxtd2aCE+LlM6Y+CxOdr";

  # better performance on limited RAM
  zramSwap = {
    enable = true;
    memoryPercent = 50;
  };
}
