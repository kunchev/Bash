#!/bin/bash

# Petyo Kunchev 
# Bootstrap CentOS 7 x86_64, will also work on Red Hat 7.x if active yum repositories are present
# Minimal setup

# Changelog:
# 20.3.2019 - Initial version
#
# 24.3.2019 - Moved section with hostname setup at the beginning
#           - Added backup for '/etc/hostname' file before modifying it
#           - Added function 'confirm' to as you whether you want to continue with script at all
#           - Added simple check if distribution is CentOS/RHEL
#           - Added simple echo message before each section start for information
#           - Added 'open-vm-tools' package, remove it if your system is different guest os or bare-metal
#
# 17.6.2019 - Added extra comments
#           - Added command that show basic information for your server


confirm() {
    # call with a prompt string or use a default
    read -r -p "${1:-Are you sure you want to continue with script? [y/N]} " resp
    case "$resp" in
        [yY][eE][sS]|[yY])
            true
            ;;
        *)
            echo "You typed [n/N] or just pressed [Enter], exiting"
            exit 0
            ;;
    esac
}

# clear
clear
sleep 1

# logging
scriptnoext=$0
exec &> >(tee -a "${scriptnoext%.*}.log_`date +%Y-%m-%d`")

# check if you are running this script as root
echo ""
echo "starting user check"
echo ""

if [ "$(id -u)" != "0" ]; then
    echo -e "\nthis script must be run as root, exiting..!!" 1>&2
    exit 1
else
   echo -e "\nrunning as root, continuing"
fi

# cinfirm and continue/exit
confirm

# check if os is centos
echo ""
echo "starting os check"
echo ""

if [ ! -f /etc/redhat-release ]; then
    echo "not running 'CentOS/RHEL', exiting" 1>&2
    exit 1
else
   echo "running centos/rhel, continuing"
fi

# backup folder for the original configuration files
echo ""
echo "creating '/root/backups' folder"
echo ""

mkdir /root/backups

# hostname
echo ""
echo "setting hostname and hosts record"
echo ""

cp /etc/hostname /root/backups/hostname.orig
read -p "Enter desired hostname: " servername
hostnamectl set-hostname $servername
echo "${servername} set as hostname - `hostname -s`"
cp /etc/hosts /root/backups/hosts.orig
echo "`ip route get 1 | awk '{print $NF;exit}'` $servername" >> /etc/hosts

# 'noatime' in fstab
echo ""
echo "setting 'noatime'  mount option in /etc/fstab"
echo ""

cp /etc/fstab /root/backups/fstab.orig
sed -i 's/defaults/defaults,noatime/g' /etc/fstab
for partition in $(df -hPT | grep -v tmpfs | grep -v Mounted | awk '{print $7}'); do mount -o remount $partition; done

# yum
echo ""
echo "installing packages and performing os update"
echo ""

yum install deltarpm -y
yum install epel-release -y
yum makecache fast
#yum install ansible -y # uncomment line if you want ansible installed
yum update -y
# remove any unwanted package(s)
yum install open-vm-tools htop screen curl vim nano dos2unix lsof man tree zip unzip mc bc mlocate git wget rsync lynx chrony -y 
updatedb

# services
echo ""
echo "services - enabling 'chrony', disabling 'firewalld'"
echo ""

systemctl enable chronyd
systemctl disable firewalld # comment line if you want to continue using firewalld

# selinux
echo ""
echo "disabling 'selinux'"
echo ""

setenforce 0
sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config && cat /etc/selinux/config # comment line if you want to continue using selinux in enforcing mode

# timezone
echo ""
echo "setting timzone 'Europe/Sofia'"
echo ""

timedatectl set-timezone Europe/Sofia # change timezone according to your needs

# ssh key generation
echo ""
echo "generating ssh key for 'root'"
echo ""

ssh-keygen -t rsa -b 2048 -N "" -f ~/.ssh/id_rsa

# display basic system info
# user
echo "Hello, $USER"
echo
echo "Today's date is: `date`."
echo

# system name
echo "Hostname:"
hostname -f

# active users
echo "Active users:"
w | cut -d ' ' -f 1 | grep -v USER | sort -u
echo

# system information using uname command
echo "This is `uname -s` running on a `uname -m` CPU."
echo

# uptime
echo "Uptime is:"
uptime
echo

# free mem
echo "System memory info:"
free
echo

# disk usage
echo "Disk Space Utilization:"
df -mh
echo 

# kernel and other info:
echo "Kernel:"
uname -a

# complete and reboot/shutdown
sleep 1
echo ""
echo "complete, shutting down"
echo ""
reboot
#poweroff # uncomment this line if you want to poweroff the system after script completes
