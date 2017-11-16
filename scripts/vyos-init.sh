# #!/bin/bash
source /opt/vyatta/etc/functions/script-template

# Add Debian Jessie repository
set system package repository squeeze url 'http://archive.debian.org/debian'
set system package repository squeeze distribution 'squeeze'
set system package repository squeeze components 'main contrib non-free'
commit
save

# Install open-vm-tools
sudo apt-get update
sudo apt-get -y install open-vm-tools

# Delete Debian Jessie repository
delete system package repository squeeze
commit
save
