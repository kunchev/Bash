#!/bin/bash

# 1.) Clear the screen:
clear

# 2.) Check if you are running this script under root privileges:
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root, exiting..!!" 1>&2
    exit 87
fi

# 3.) Make sure that you are running a GNU/Linux distribution:
if [ `uname -s` != Linux ]; then
    echo "ERROR: Unsupported OS detected! This script only detects GNU/Linux distributions!" 1>&2
    exit 1
fi

# 4.) Install MariaDB server and configure autostart:
yum -y install mariadb-server mariadb
systemctl start mariadb.service
systemctl enable mariadb.service
mysql_secure_installation

# 5.) Install Apache2 and configre autostart:
yum -y install httpd
systemctl start httpd.service
systemctl enable httpd.service

# 6.) Open firewall ports for http/https:
firewall-cmd --permanent --zone=public --add-service=http
firewall-cmd --permanent --zone=public --add-service=https
firewall-cmd --reload

# 7.) Install PHP5:
yum -y install php
#yum -y install php-fpm # optional package, uncomment if needed

##
echo "Installation has completed!"
