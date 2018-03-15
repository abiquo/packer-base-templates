#!/bin/bash

yum -y install python-devel python-setuptools cloud-init

tmpcfg=$(mktemp -d)
cp -rp /etc/cloud/* $tmpcfg/

tmpdir=$(mktemp -d)

cd $tmpdir
curl -L https://launchpad.net/cloud-init/trunk/18.1/+download/cloud-init-18.1.tar.gz -o cloud-init-18.1.tar.gz
tar xf cloud-init-18.1.tar.gz
cd cloud-init-18.1

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
  /usr/bin/systemctl enable cloud-init-local
  /usr/bin/systemctl enable cloud-init
  /usr/bin/systemctl enable cloud-config
  /usr/bin/systemctl enable cloud-final
else
  /sbin/chkconfig --add cloud-init
  /sbin/chkconfig --add cloud-init-local
  /sbin/chkconfig --add cloud-config
  /sbin/chkconfig --add cloud-final
  /sbin/chkconfig cloud-init-local on
  /sbin/chkconfig cloud-init on
  /sbin/chkconfig cloud-config on
  /sbin/chkconfig cloud-final on
fi

cd
rm -rf $tmpcfg
rm -rf $tmpdir
