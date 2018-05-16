#!/bin/bash
if [ -f "/etc/redhat-release" ]; then # Is a CentOS machine
  # C7 NM ifname
  if [ -x /bin/systemctl ]; then # Check if C7
    nmcli connection modify eth0 ifname eth0
  fi
  
  sed -i '/HWADDR/d' /etc/sysconfig/network-scripts/ifcfg-eth0
  sed -i '/UUID/d' /etc/sysconfig/network-scripts/ifcfg-eth0

  echo "source .bash_aliases" >> ~/.bashrc
fi

if [ -f /etc/lsb-release ]; then # Check if Ubuntu
  source /etc/lsb-release
  if [ "$DISTRIB_ID" == "Ubuntu" ]; then
    apt-get -y autoremove
    apt-get clean
  fi

  if [ "$DISTRIB_RELEASE" == "15.10" ] || [ "$DISTRIB_RELEASE" == "16.04" ]; then
    sed -i 's/\\(GRUB_CMDLINE_LINUX_DEFAULT=\\).*/\\1"net.ifnames=0 biosdevname=0"/g' /etc/default/grub
    update-grub
  fi
fi

# Delete udev net rules
rm -f /etc/udev/rules.d/70-persistent-net.rules
rm -f /var/lib/dhclient/*.lease
rm -f /var/lib/dhcp/*.lease
rm -f /var/lib/NetworkManager/*.lease
rm -f /etc/netplan/*

# Make sure disk is zeroed
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY
