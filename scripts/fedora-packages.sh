#!/bin/bash

# Add virtio to dracut
echo "add_drivers+=\"virtio virtio_blk virtio_net virtio_pci hv_vmbus hv_storvsc hv_netvsc\"" >> /etc/dracut.conf

dnf -y install epel-release
dnf -y update
dnf -y install ntp curl vim htop ccze wget git dnf-utils yum-cron-security \
  kernel-devel bash-completion make gcc gcc-c++ haveged jq sudo unzip

systemctl enable haveged

systemctl disable NetworkManager
systemctl stop NetworkManager
systemctl disable NetworkManager-wait-online
systemctl stop NetworkManager-wait-online

systemctl enable network
# systemctl start network
