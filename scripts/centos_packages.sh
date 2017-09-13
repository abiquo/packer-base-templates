#!/bin/bash

# Add virtio to dracut
echo "add_drivers+=\"virtio virtio_blk virtio_net virtio_pci\"" >> /etc/dracut.conf

yum -y install epel-release
yum -y update
yum -y install ntp curl vim htop ccze wget git yum-utils unzip yum-cron kernel-devel bash-completion make gcc gcc-c++ haveged

if [ -x "/usr/bin/systemctl" ]; then
  systemctl enable haveged
  systemctl disable NetworkManager
  systemctl stop NetworkManager; ifdown eth0; ifup eth0
else
  chkconfig haveged on
fi
