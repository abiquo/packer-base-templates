#!/bin/bash

ISSUE=$(cat /etc/issue)

if [[ "$ISSUE" == *"buntu"* ]]; then
  apt-get -y install open-vm-tools
elif [[ "$ISSUE" == *"openSUSE"* ]]; then
  zypper -n --non-interactive install open-vm-tools
else
	yum -y install open-vm-tools
fi
