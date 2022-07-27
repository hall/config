# switch

Boot into UBoot (by interrupting boot over console), execute `run onie_bootcmd` to boot into ONIE
(use `onie-discovery-stop`, if discovery is polling); execute `onie-nos-install <image>`.

The current `<image>` is

    http://opennetlinux.org/binaries/2019.03.28.02.33.05a8ab52a68c7a57307ca8b5da7fa667b5c5689b/ONL-master-ONL-OS9-2019-03-28.0243-05a8ab5-ARMEL-INSTALLED-INSTALLER

for compatibility with EdgeCore-provided OpenNSL (kernel `4.14.49-OpenNetworkLinux-armel`) and FRR (`armhf`).

Default creds are `root:onl`.
Make the following changes.

- update password (`passwd`)
- add ssh public key (`~/.ssh/authorized_keys`)
- update hostname (`/etc/hostname`) to `switch`
- add boot commands`/etc/rc.local`
  ```
  service ssh start
  dhclient ma1
  opennsl_setup
  ```
- `dpkg -i 'opennsl-accton_3.5.0.3 accton5.4-1_armel.deb'`

- `/etc/opennsl/opennsl.cfg`

 - install https://deb.frrouting.org/
- `/etc/frr/daemons`

 - packages
   - apt-transport-https
   - vim
   - curl
   - gnupg

 `/etc/modules`
   - poe
   - poe_bcm59121


  - `/usr/bin/opennsl-accton/examples`