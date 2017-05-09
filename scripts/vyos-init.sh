#!/bin/bash

set -e
set -x

sudo sed -i -e 's,^.*:/sbin/getty\s\+.*\s\+tty[2-6],#\0,' /etc/inittab

WRAPPER=/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper

$WRAPPER begin
$WRAPPER set system package repository vyatta4people url http://packages.vyatta4people.org/debian
$WRAPPER set system package repository vyatta4people distribution experimental
$WRAPPER set system package repository vyatta4people components main
$WRAPPER commit
$WRAPPER save
$WRAPPER end

sudo sed -i /vyos/d /etc/apt/sources.list
sudo gpg --keyserver pgpkeys.mit.edu --recv-key AED4B06F473041FA
sudo gpg -a --export AED4B06F473041FA | sudo apt-key add -
sudo apt-get update
sudo apt-get -y --force-yes install vyatta-clone-helper
