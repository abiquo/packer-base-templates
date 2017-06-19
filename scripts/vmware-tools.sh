#!/bin/bash

ISSUE=$(cat /etc/issue)

if [[ -x /usr/bin/apt-get ]]; then
  apt-get -y install open-vm-tools
elif [[ -x /usr/bin/zypper ]]; then
  zypper -n --non-interactive install open-vm-tools
elif [ -x /usr/bin/yum ]; then
	yum -y install open-vm-tools
fi
