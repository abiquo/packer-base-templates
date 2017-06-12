#!/bin/bash

apk --update add py-setuptools py-urllib3 py-chardet py-certifi py-idna cloud-init

tmpcfg=$(mktemp -d)
cp -rp /etc/cloud/* $tmpcfg/

tmpdir=$(mktemp -d)

cd $tmpdir
curl -L https://launchpad.net/cloud-init/trunk/0.7.9/+download/cloud-init-0.7.9.tar.gz -o cloud-init-0.7.9.tar.gz
tar xf cloud-init-0.7.9.tar.gz
cd cloud-init-0.7.9
python setup.py install --init-system=sysvinit_openrc
chmod 755 /etc/init.d/cloud-init*

rm -rf /etc/cloud/*
cp -rp $tmpcfg/* /etc/cloud/

cat << ENOENT >> /etc/cloud/cloud.cfg
datasource_list: [ ConfigDrive ]
ENOENT
sed s/disable_root.*/disable_root:\ 0/g /etc/cloud/cloud.cfg
sed s/ssh_pwauth.*/ssh_pwauth:\ 1/g /etc/cloud/cloud.cfg

rc-update add cloud-init default

cd
rm -rf $tmpcfg
rm -rf $tmpdir
