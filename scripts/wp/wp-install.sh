#!/bin/bash
systemctl restart mariadb
systemctl restart httpd

## Create site
/usr/local/bin/wp core download --path=/var/www/html/
cd /var/www/html/
/usr/local/bin/wp config create --dbname=wordpress --dbuser=root --dbhost=localhost
/usr/local/bin/wp db create
