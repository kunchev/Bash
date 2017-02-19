#!/bin/bash

# 1.) Clear the screen:
clear

# 2.) Check if you are running this script under root privileges:
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root, exiting..!!" 1>&2
    exit 1
fi

# 3.) Make sure that you are running a RedHat/CentOS 7.x GNU/Linux distribution:
if [ `rpm -qa \*-release | grep -Ei "oracle|redhat|centos" | cut -d"-" -f3` != 7 ]; then
    echo "ERROR: Unsupported OS detected! This script only detects GNU/Linux distributions!" 1>&2
    exit 1
fi

# 4.) Install MariaDB server and enable autostart:
yum -y install mariadb-server mariadb
systemctl start mariadb.service
systemctl enable mariadb.service
mysql_secure_installation

# 5.) Install Apache2 and enable autostart:
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
echo "Your system's IP address is: `hostname -i | cut -d " " -f 2`
