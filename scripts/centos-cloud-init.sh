#!/bin/bash

yum -y install python-devel python-setuptools cloud-init

tmpcfg=$(mktemp -d)
cp -rp /etc/cloud/* $tmpcfg/

tmpdir=$(mktemp -d)

cd $tmpdir
wget https://launchpad.net/cloud-init/trunk/0.7.9/+download/cloud-init-0.7.9.tar.gz
tar xf cloud-init-0.7.9.tar.gz
cd cloud-init-0.7.9

if [ -x "/usr/bin/systemctl" ]; then
  python setup.py install --init-system=systemd
else
  python setup.py install --init-system=sysvinit
fi

rm -rf /etc/cloud/*
cp -rp $tmpcfg/* /etc/cloud/

cat << ENOENT >> /etc/cloud/cloud.cfg
datasource_list: [ ConfigDrive ]
ENOENT
sed s/disable_root.*/disable_root:\ 0/g /etc/cloud/cloud.cfg
sed s/ssh_pwauth.*/ssh_pwauth:\ 1/g /etc/cloud/cloud.cfg

if [ -x "/usr/bin/systemctl" ]; then
  /usr/bin/systemctl enable cloud-init
else
  /sbin/chkconfig --add cloud-init
  /sbin/chkconfig cloud-init on
fi

cd
rm -rf $tmpcfg
rm -rf $tmpdir
