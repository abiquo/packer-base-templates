#!/bin/bash
zypper -n --non-interactive install git
git clone https://github.com/abiquo/abiquo-chef-agent /tmp/abiquo-chef-agent
cd /tmp/abiquo-chef-agent
git checkout suse
bash install/install-opensuse.sh
cp bin/abiquo-chef-run /usr/bin/abiquo-chef-run.ruby2.1
