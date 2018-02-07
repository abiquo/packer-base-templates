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
rc-update add cloud-init-local default
rc-update add cloud-init default
rc-update add cloud-config default
rc-update add cloud-final default
cat << ENOENT >> /etc/cloud/cloud.cfg
datasource_list: [ ConfigDrive ]
ENOENT

# Entropy for everyone
apk --update add rng-tools
echo 'RNGD_OPTS="--no-drng=1 --no-tpm=1 -r /dev/urandom"' > /etc/conf.d/rngd
rc-update add rngd boot

# Change default ash to bash
apk --update add bash sudo
sed -i 's,/bin/ash,/bin/bash,g' /etc/passwd

rm -rf /etc/ssh/ssh_host_*
cat <<EOF >> /etc/ssh/sshd_config
UseDNS no
EOF

cat <<EOF > /etc/profile.d/aliases.sh
alias ll="ls -l --color"
EOF
