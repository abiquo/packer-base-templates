#!/bin/bash
sed -i "/^deb cdrom:/s/^/#/" /etc/apt/sources.list
DEBIAN_FRONTEND=noninteractive apt-get -y --force-yes update && apt-get -y dist-upgrade
DEBIAN_FRONTEND=noninteractive apt-get -y --force-yes install perl ntp curl vim htop ccze wget git gnupg2 unzip
