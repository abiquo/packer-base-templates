#!/bin/bash

apt-get -y install python-dev python-setuptools cloud-init

tmpcfg=$(mktemp -d)
cp -rp /etc/cloud/* $tmpcfg/

tmpdir=$(mktemp -d)

cd $tmpdir

wget https://launchpad.net/cloud-init/trunk/0.7.9/+download/cloud-init-0.7.9.tar.gz
tar xf cloud-init-0.7.9.tar.gz
cd cloud-init-0.7.9

if [ -x "/bin/systemctl" ]; then
  python setup.py install --init-system=systemd
else
  python setup.py install --init-system=upstart
fi

rm -rf /etc/cloud/*
cp -rp $tmpcfg/* /etc/cloud/

cat << ENOENT >> /etc/cloud/cloud.cfg
datasource_list: [ ConfigDrive ]
ENOENT
sed s/disable_root.*/disable_root:\ 0/g /etc/cloud/cloud.cfg
sed s/ssh_pwauth.*/ssh_pwauth:\ 1/g /etc/cloud/cloud.cfg

if [ -x "/bin/systemctl" ]; then
  /bin/systemctl enable cloud-init
else
  /usr/sbin/update-rc.d cloud-init defaults
fi

cd
rm -rf $tmpcfg
rm -rf $tmpdir
