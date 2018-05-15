#!/bin/bash

if [ -f /etc/redhat-release ] && grep -qi centos /etc/redhat-release; then
  ## CENTOS
  # PHP 7.2
  curl 'https://setup.ius.io/' -o setup-ius.sh
  sudo bash setup-ius.sh

  sudo yum -y update
  sudo yum -y install ntp curl vim htop ccze wget git yum-utils unzip \
         yum-cron kernel-devel bash-completion make gcc gcc-c++ \
         haveged jq php72u-json mod_php72u php72u-cli php72u-mysqlnd \
         mariadb mariadb-server less

  sudo systemctl enable haveged
  sudo systemctl enable httpd
  sudo systemctl enable mariadb

  ## WP cli
  sudo curl -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
  sudo chmod +x /usr/local/bin/wp
  wp --info
fi

if [ -f /etc/system-release ] && grep -q "Amazon Linux release 2" /etc/system-release; then
  ## CENTOS
  # PHP 7.2
  sudo amazon-linux-extras install php7.2 lamp-mariadb10.2-php7.2

  sudo yum -y update
  sudo yum -y install ntp curl vim htop ccze wget git yum-utils unzip \
         yum-cron kernel-devel bash-completion make gcc gcc-c++ \
         haveged jq less httpd mariadb-server

  sudo systemctl enable httpd
  sudo systemctl enable mariadb

  ## WP cli
  sudo curl -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
  sudo chmod +x /usr/local/bin/wp
  wp --info
fi
