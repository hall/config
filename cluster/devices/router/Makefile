define PACKAGES
block-mount
e2fsprogs
kmod-fs-ext4
kmod-usb-storage
#usbutils

haproxy

luci-app-openvpn
luci-app-https-dns-proxy
luci-app-sqm
luci-app-vpn-policy-routing
luci-app-wireguard
luci-app-firewall
luci-mod-rpc

prometheus-node-exporter-lua
endef

SOURCE=${HOME}/openwrt-imagebuilder-ipq806x-generic.Linux-x86_64

build:
	make -C ${SOURCE} image BIN_DIR=${PWD}/bin FILES=files/ PACKAGES=$${PACKAGES}
