#!/bin/bash

ISSUE=$(cat /etc/issue)

apt-get -y install python-dev python-setuptools python-pip cloud-init

# Ubuntu / Debian
if [[ "$ISSUE" == "Ubuntu 18."* ]]; then
  # Ubuntu 18.04 has already a recent version of Cloud Init.
  echo "Skip source install for Cloud Init"
else
  tmpcfg=$(mktemp -d)
  cp -rp /etc/cloud/* $tmpcfg/

  tmpdir=$(mktemp -d)

  cd $tmpdir

  wget https://launchpad.net/cloud-init/trunk/18.1/+download/cloud-init-18.1.tar.gz
  tar xf cloud-init-18.1.tar.gz
  cd cloud-init-18.1

  pip install -r requirements.txt

  if [ -x "/bin/systemctl" ]; then
    python setup.py install --init-system=systemd
  else
    python setup.py install --init-system=upstart
  fi

  rm -rf /etc/cloud/*
  cp -rp $tmpcfg/* /etc/cloud/

  cd
  rm -rf $tmpcfg
  rm -rf $tmpdir
fi

if [ -f /etc/cloud/cloud.cfg.d/90_dpkg.cfg ]; then
  sed -i 's,^datasource_list.*,datasource_list: [ ConfigDrive ],g' /etc/cloud/cloud.cfg.d/90_dpkg.cfg
else
  cat << ENOENT >> /etc/cloud/cloud.cfg
datasource_list: [ ConfigDrive ]
ENOENT
fi
sed s/disable_root.*/disable_root:\ 0/g /etc/cloud/cloud.cfg
sed s/ssh_pwauth.*/ssh_pwauth:\ 1/g /etc/cloud/cloud.cfg

cat << ENOENT > /etc/network/interfaces
source /etc/network/interfaces.d/*
ENOENT

if [ -x "/bin/systemctl" ]; then
  /bin/systemctl enable cloud-init-local
  /bin/systemctl enable cloud-init
  /bin/systemctl enable cloud-config
  /bin/systemctl enable cloud-final
else
  /usr/sbin/update-rc.d cloud-init-local defaults
  /usr/sbin/update-rc.d cloud-init defaults
  /usr/sbin/update-rc.d cloud-config defaults
  /usr/sbin/update-rc.d cloud-config defaults
fi
