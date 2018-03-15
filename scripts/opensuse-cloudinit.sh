#!/bin/bash
issue=$(cat /etc/issue)
repo=$(echo $v | sed -r s/.*openSUSE\ \(.*\.[0-9]+\).*/\\1/ | sed s/\ /_/g)

zypper addrepo http://download.opensuse.org/repositories/Cloud:Tools/openSUSE_$repo/Cloud:Tools.repo
zypper refresh
zypper -n --non-interactive install python-setuptools python-devel cloud-init

tmpcfg=$(mktemp -d)
cp -rp /etc/cloud/* $tmpcfg/

tmpdir=$(mktemp -d)

cd $tmpdir
wget https://launchpad.net/cloud-init/trunk/18.1/+download/cloud-init-18.1.tar.gz
tar xf cloud-init-18.1.tar.gz
cd cloud-init-18.1
python setup.py install --init-system=systemd

rm -rf /etc/cloud/*
cp -rp $tmpcfg/* /etc/cloud/

cat << ENOENT >> /etc/cloud/cloud.cfg
datasource_list: [ ConfigDrive ]
ENOENT
sed s/disable_root.*/disable_root:\ 0/g /etc/cloud/cloud.cfg
sed s/ssh_pwauth.*/ssh_pwauth:\ 1/g /etc/cloud/cloud.cfg

/usr/bin/systemctl enable cloud-init
/usr/bin/systemctl enable cloud-init-local
/usr/bin/systemctl enable cloud-config
/usr/bin/systemctl enable cloud-final

cd
rm -rf $tmpcfg
rm -rf $tmpdir
