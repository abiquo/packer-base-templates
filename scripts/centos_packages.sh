#!/bin/bash

# Add virtio to dracut
echo "add_drivers+=\"virtio virtio_blk virtio_net virtio_pci\"" >> /etc/dracut.conf

yum -y install epel-release
yum -y update
yum -y install ntp curl vim htop ccze wget git yum-utils unzip yum-cron kernel-devel bash-completion make gcc gcc-c++ haveged

if [ -x "/usr/bin/systemctl" ]; then
  systemctl enable haveged
else
  chkconfig haveged on
fi

# cat << ENOENT >> /etc/cloud/cloud.cfg
# datasource_list: [ ConfigDrive ]
# ENOENT
# sed s/disable_root.*/disable_root:\ 0/g /etc/cloud/cloud.cfg
# sed s/ssh_pwauth.*/ssh_pwauth:\ 1/g /etc/cloud/cloud.cfg
