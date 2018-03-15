#!/bin/bash -xe
sed -i "s,alpine/.*/,alpine/edge/,g" /etc/apk/repositories

apk --update add py-setuptools py-urllib3 py-chardet py-certifi py-idna cloud-init curl
easy_install-2.7 pip
pip install six

tmpcfg=$(mktemp -d)
cp -rp /etc/cloud/* $tmpcfg/

tmpdir=$(mktemp -d)

cd $tmpdir
curl -L https://launchpad.net/cloud-init/trunk/18.1/+download/cloud-init-18.1.tar.gz -o cloud-init-18.1.tar.gz
tar xf cloud-init-18.1.tar.gz
cd cloud-init-18.1
python setup.py install --init-system=sysvinit_openrc
chmod 755 /etc/init.d/cloud-init*

rm -rf /etc/cloud/*
cp -rp $tmpcfg/* /etc/cloud/

cat << ENOENT >> /etc/cloud/cloud.cfg
datasource_list: [ ConfigDrive ]
ENOENT

rc-update add cloud-init default

cd
rm -rf $tmpcfg
rm -rf $tmpdir

# Make sure CD support is loaded on boot
echo "iso9660" >> /etc/modules
