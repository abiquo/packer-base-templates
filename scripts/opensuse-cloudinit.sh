#!/bin/bash
source /etc/os-release
repo=$(echo $PRETTY_NAME | sed s/\ /_/g)

zypper addrepo http://download.opensuse.org/repositories/Cloud:Tools/openSUSE_$repo/Cloud:Tools.repo
zypper refresh
zypper -n --non-interactive install python-setuptools python-pip python-devel cloud-init

if [ "$VERSION" == "42"* ]; then
  tmpcfg=$(mktemp -d)
  cp -rp /etc/cloud/* $tmpcfg/

  tmpdir=$(mktemp -d)

  cd $tmpdir
  wget https://launchpad.net/cloud-init/trunk/18.1/+download/cloud-init-18.1.tar.gz
  tar xf cloud-init-18.1.tar.gz
  cd cloud-init-18.1
  pip install -r requirements.txt
  python setup.py install --init-system=systemd

  rm -rf /etc/cloud/*
  cp -rp $tmpcfg/* /etc/cloud/

  cd
  rm -rf $tmpcfg
  rm -rf $tmpdir
fi

cat << ENOENT >> /etc/cloud/cloud.cfg
# Adapted default config for (open)SUSE systems

users:
 - default

disable_root: false
preserve_hostname: false
syslog_fix_perms: root:root
mount_default_fields: [~, ~, 'auto', 'defaults', '0', '2']

# The modules that run in the 'init' stage
cloud_init_modules:
 - migrator
 - bootcmd
 - write-files
 - growpart
 - resizefs
 - set_hostname
 - update_hostname
 - update_etc_hosts
 - ca-certs
 - rsyslog
 - users-groups
 - ssh

# The modules that run in the 'config' stage
cloud_config_modules:
 - mounts
 - ssh-import-id
 - locale
 - set-passwords
 - package-update-upgrade-install
 - timezone
 - puppet
 - chef
 - salt-minion
 - mcollective
 - disable-ec2-metadata
 - runcmd
 - byobu

# The modules that run in the 'final' stage
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
 - power-state-change

# System and/or distro specific settings
system_info:
   distro: sles
   default_user:
    name: opensuse
    lock_passwd: true
    gecos: Cloud User
    groups: [wheel, adm, systemd-journal]
    sudo: ["ALL=(ALL) NOPASSWD:ALL"]
    shell: /bin/bash
   paths:
      cloud_dir: /var/lib/cloud/
      templates_dir: /etc/cloud/templates/
   ssh_svcname: sshd
datasource_list: [ ConfigDrive ]
ENOENT

/usr/bin/systemctl enable cloud-init
/usr/bin/systemctl enable cloud-init-local
/usr/bin/systemctl enable cloud-config
/usr/bin/systemctl enable cloud-final
