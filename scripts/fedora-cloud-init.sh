#!/bin/bash

dnf -y install python-devel python-setuptools cloud-init libyaml python-pip
pip install pyyaml requests

tmpcfg=$(mktemp -d)
cp -rp /etc/cloud/* $tmpcfg/

tmpdir=$(mktemp -d)

cd $tmpdir
curl -L https://launchpad.net/cloud-init/trunk/18.1/+download/cloud-init-18.1.tar.gz -o cloud-init-18.1.tar.gz
tar xf cloud-init-18.1.tar.gz
cd cloud-init-18.1
python setup.py install --init-system=systemd

rm -rf /etc/cloud/*
cp -rp $tmpcfg/* /etc/cloud/

cat << ENOENT >> /etc/cloud/cloud.cfg
datasource_list: [ ConfigDrive ]
ENOENT

/usr/bin/systemctl enable cloud-init-local
/usr/bin/systemctl enable cloud-init
/usr/bin/systemctl enable cloud-config
/usr/bin/systemctl enable cloud-final

cd
rm -rf $tmpcfg
rm -rf $tmpdir
