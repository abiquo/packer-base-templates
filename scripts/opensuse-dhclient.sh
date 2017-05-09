#!/bin/bash -e

# Add virtio to dracut
echo "add_drivers+=\"virtio virtio_blk virtio_net virtio_pci\"" >> /etc/dracut.conf
mkinitrd

# Disable wicked
systemctl is-active network.service && systemctl stop network.service
systemctl is-active wickedd.service && systemctl stop wickedd.service
systemctl disable wicked.service
systemctl enable NetworkManager
systemctl enable NetworkManager-wait-online.service
systemctl start NetworkManager

# Use "dhclient" DHCP client for compatibility with Piston
echo 'DHCLIENT_BIN="dhclient"' >> '/etc/sysconfig/network/dhcp'

# Make dhclient start at boot
touch '/etc/init.d/dhclient-script'
echo '#!/bin/bash' >> '/etc/init.d/dhclient-script'
echo 'dhclient' >> '/etc/init.d/dhclient-script'
chmod u+x '/etc/init.d/dhclient-script'
