#!/bin/bash
sudo sed -i.bak '/HWADDR/d' /etc/sysconfig/network-scripts/ifcfg-eth0
sudo sed -i.bak '/UUID/d' /etc/sysconfig/network-scripts/ifcfg-eth0

# Delete udev net rules
[ -f /etc/udev/rules.d/70-persistent-net.rules ] && sudo rm -f /etc/udev/rules.d/70-persistent-net.rules
[ -d /var/lib/dhclient ] && sudo rm -f /var/lib/dhclient/*.lease
[ -d /var/lib/dhcp ] && sudo rm -f /var/lib/dhcp/*.lease
[ -d /var/lib/NetworkManager ] && sudo rm -f /var/lib/NetworkManager/*.lease

# Make sure disk is zeroed
sudo dd if=/dev/zero of=/EMPTY bs=1M
sudo rm -f /EMPTY
