#!/bin/bash

yum -y install python-devel python-setuptools python-pip cloud-init-18.2

tmpcfg=$(mktemp -d)
cp -rp /etc/cloud/* $tmpcfg/

tmpdir=$(mktemp -d)

cd $tmpdir
curl -L https://launchpad.net/cloud-init/trunk/18.1/+download/cloud-init-18.1.tar.gz -o cloud-init-18.1.tar.gz
tar xf cloud-init-18.1.tar.gz
cd cloud-init-18.1

pip install -r requirements.txt
pip install --upgrade six

if [ -x "/usr/bin/systemctl" ]; then
  python setup.py install --init-system=systemd
else
  python setup.py install --init-system=sysvinit
fi

rm -rf /etc/cloud/*
cp -rp $tmpcfg/* /etc/cloud/

cat << ENOENT >> /etc/cloud/cloud.cfg
# vim:syntax=yaml

users:
 - default

disable_root: 1
ssh_pwauth:   0

locale_configfile: /etc/sysconfig/i18n
mount_default_fields: [~, ~, 'auto', 'defaults,nofail', '0', '2']
resize_rootfs_tmp: /dev
ssh_deletekeys: 1
ssh_genkeytypes: ~
syslog_fix_perms: ~

cloud_init_modules:
 - migrator
 - bootcmd
 - write-files
 - growpart
 - resizefs
 - set_hostname
 - update_hostname
 - update_etc_hosts
 - rsyslog
 - users-groups
 - ssh
 - disk_setup

cloud_config_modules:
 - mounts
 - locale
 - set-passwords
 - yum-add-repo
 - package-update-upgrade-install
 - timezone
 - puppet
 - chef
 - salt-minion
 - mcollective
 - disable-ec2-metadata
 - runcmd

cloud_final_modules:
 - rightscale_userdata
 - scripts-per-once
 - scripts-per-boot
 - scripts-per-instance
 - scripts-user
 - ssh-authkey-fingerprints
 - keys-to-console
 - phone-home
 - final-message

system_info:
  default_user:
    name: centos
    lock_passwd: true
    gecos: Cloud User
    groups: [wheel, adm, systemd-journal]
    sudo: ["ALL=(ALL) NOPASSWD:ALL"]
    shell: /bin/bash
  distro: rhel
  paths:
    cloud_dir: /var/lib/cloud
    templates_dir: /etc/cloud/templates
  ssh_svcname: sshd

datasource_list: [ ConfigDrive ]
ENOENT

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
