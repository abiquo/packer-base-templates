#!/bin/bash -x

ISSUE=$(cat /etc/issue)

if [[ "$ISSUE" == "Ubuntu"* ]] || [[ "$ISSUE" == "Debian"* ]]; then
  apt-get -y install open-vm-tools
  exit $?
fi

if [[ "$ISSUE" == *"openSUSE"* ]]; then
  zypper -n --non-interactive install open-vm-tools
  echo "force_drivers+=\"virtio virtio_blk virtio_net virtio_pci vmw_pvscsi vmxnet3 vmw_baloon hv_storsvc hv_vmbus hv_utils hv_ballon hv_netsvc\"" >> /etc/dracut.conf.d/01-dist.conf
  dracut -f
  exit $?
fi

if [[ "$ISSUE" == *"CentOS"* ]] || [[ "$ISSUE" == *"Atomic"* ]]; then
	yum -y install open-vm-tools
  dracut -f
  exit $?
fi

# Fedora
if [[ -f "/etc/fedora-release" ]]; then
  dnf -y install open-vm-tools
  dracut -f
  exit $?
fi
