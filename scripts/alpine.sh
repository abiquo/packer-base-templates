#!/bin/bash -x

# Enable all repos
sed -i 's/^#http/http/g' /etc/apk/repositories

# NTP
setup-ntp -c openntpd

# vm-tools
apk --update add open-vm-tools
rm -rf /var/cache/apk/*
rc-update add open-vm-tools default

# cloud-init
apk --update add cloud-init
rc-update add cloud-init default
cat << ENOENT >> /etc/cloud/cloud.cfg
datasource_list: [ ConfigDrive ]
ENOENT

# Entropy for everyone
apk --update add rng-tools
echo 'RNGD_OPTS="--no-drng=1 --no-tpm=1 -r /dev/urandom"' > /etc/conf.d/rngd
rc-update add rngd boot

# Change default ash to bash
apk --update add bash
sed -i 's,/bin/ash,/bin/bash,g' /etc/passwd

rm -rf /etc/ssh/ssh_host_*
cat <<EOF >> /etc/ssh/sshd_config
UseDNS no
EOF

# Try to make it boot in Hyper-V
sed -i '/APPEND/ s/$/ acpi=off modules=hv_storsvc,hv_vmbus,hv_utils,hv_ballon,hv_netsvc/g' /boot/extlinux.conf
