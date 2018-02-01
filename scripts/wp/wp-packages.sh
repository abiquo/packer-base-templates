#!/bin/bash

# Add virtio to dracut
echo "add_drivers+=\"virtio virtio_blk virtio_net virtio_pci\"" >> /etc/dracut.conf

curl 'https://setup.ius.io/' -o setup-ius.sh
bash setup-ius.sh
yum -y update
yum -y install ntp curl vim htop ccze wget git yum-utils unzip \
       yum-cron kernel-devel bash-completion make gcc gcc-c++ \
       haveged jq php72u-json mod_php72u php72u-cli php72u-mysqlnd \
       mariadb mariadb-server less sudo

systemctl enable haveged
systemctl disable NetworkManager
systemctl stop NetworkManager; ifdown eth0; ifup eth0

## WP cli
curl -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x /usr/local/bin/wp
wp --info
