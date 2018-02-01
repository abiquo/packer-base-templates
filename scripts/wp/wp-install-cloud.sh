#!/bin/bash
sudo systemctl restart mariadb
sudo systemctl restart httpd

## Create site
sudo /usr/local/bin/wp core download --path=/var/www/html/
cd /var/www/html/
sudo /usr/local/bin/wp config create --dbname=wordpress --dbuser=root --dbhost=localhost
sudo /usr/local/bin/wp db create
