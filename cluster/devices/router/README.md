# router

OpenWRT running on a MikroTik RB3011.

Source until upstreamed: https://github.com/adron-s/openwrt-rb3011

## build

https://openwrt.org/docs/guide-user/additional-software/imagebuilder



## config

 - `/etc/dnsmasq.conf`

    ```
    dhcp-option=6,{{ address.ip.dns }}  # DNS server
    address=/.{{ hostname }}/{{ address.ip.ingress }}  # wildcard address
    ```

 - https://openwrt.org/docs/guide-user/network/wan/access.modem.through.nat#web_interface
 - wireguard

  - [pxe](https://openwrt.org/docs/guide-user/services/tftp.pxe-server)
  - wg / openvpn


- TODO: automate rebuild
- TODO: upstream support
