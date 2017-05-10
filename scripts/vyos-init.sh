#!/bin/bash

set -e
set -x

sudo sed -i -e 's,^.*:/sbin/getty\s\+.*\s\+tty[2-6],#\0,' /etc/inittab

WRAPPER=/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper

$WRAPPER begin
$WRAPPER set system package repository community components 'main'
$WRAPPER set system package repository community distribution 'current'
$WRAPPER set system package repository community url 'http://dev.packages.vyos.net/vyos'
$WRAPPER set system package repository squeeze components 'main contrib non-free'
$WRAPPER set system package repository squeeze distribution 'squeeze'
$WRAPPER set system package repository squeeze url 'http://archive.debian.org/debian'
$WRAPPER commit
$WRAPPER save
$WRAPPER end

sudo apt-get -y update
sudo apt-get -y install open-vm-tools
