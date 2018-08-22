#!/bin/bash -xe
sed -i "s,alpine/.*/,alpine/edge/,g" /etc/apk/repositories

apk --update add py-setuptools py-urllib3 py-chardet py-certifi py-idna cloud-init curl

cat << ENOENT >> /etc/cloud/cloud.cfg
datasource_list: [ ConfigDrive ]
ENOENT

rc-update add cloud-init default

# Make sure CD support is loaded on boot
echo "iso9660" >> /etc/modules
