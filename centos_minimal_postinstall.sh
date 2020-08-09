#!/bin/bash

# Perform basic postinstall configuration of CentOS/RHEL 7.x newly installed server.
# The script will perform the following configurations:
#
#  1. Performs checks if you are root and the OS is CentOS/RHEL 7
#  2. Creates backup folder for the the original config files (listed below)
#  3. Sets hostname/fqdn based on your input
#  4. Sets 'noatime' in fstab (except for swap)
#  5. Install some useful packages, performs system update (yum install, yum update)
#  6. Enables 'chronyd', disables 'firewalld' and 'selinux'
#  7. Configures time zone
#  8. Generates ssh key-pair for the root user (RSA 2048 bits)
#  9. Displays basic system parameters
#
# Active yum repositories are required for the yum install/update section.
# Script output is logged to file in the current working directory.

# License: https://github.com/kunchev/bash-scripts/blob/master/LICENSE.md


# configs
declare -r bkp_dir="/root/backups"
declare -r os_file="/etc/redhat-release"
declare -r hostname_file="/etc/hostname"
declare -r hosts_file="/etc/hosts"
declare -r mounts_file="/etc/fstab"
declare -r selinux_file="/etc/selinux/config"
declare -r major_version=8


# funcs
_confirm() {
    # call with a prompt string or use a default
    read -r -p "${1:-Are you sure you want to continue? [y/N]} " resp
    case "$resp" in
        [yY][eE][sS]|[yY])
            true
            ;;
        *)
            exit 0
            ;;
    esac
}


clear


# logging
scriptnoext=$0
exec &> >(tee -a "${scriptnoext%.*}.log_`date +%Y-%m-%d`")


# check if you are running this script as root (sudo also works)
echo "starting user check.."
if [ "$(id -u)" != "0" ]; then
    echo "error, this script must be run as root, exiting.." 1>&2
    exit 1
else
   echo "ok, running as root, continuing.."
fi


# cinfirm and continue or exit
_confirm


# check if os is centos/rhel
echo ""
echo "starting os/distribution check.."
if [ ! -f $os_file ]; then
    echo "not running 'CentOS/RHEL', exiting.." 1>&2
    exit 1
else
    full=$(cat $os_file | tr -dc '0-9.')
    major=$(cat $os_file | tr -dc '0-9.'|cut -d \. -f1)
    minor=$(cat $os_file | tr -dc '0-9.'|cut -d \. -f2)
    asynchronous=$(cat $os_file | tr -dc '0-9.'|cut -d \. -f3)
    if [ "$major" -ne "$major_version" ]; then
        echo "error, current major version: $major is not as required: $major_version, exiting.." 1>&2
        exit 1
    else
        echo "CentOS/RHEL Version: $full"
        echo "OS Major Relase: $major"
        echo "OS Minor Relase: $minor"
        echo "OS Asynchronous Relase: $asynchronous"
        sleep 1
    fi
fi


# backup folder for the original configuration files
echo ""
echo "working on $bkp_dir folder.."
if [ ! -d $bkp_dir ]; then
    echo "creating $bkp_dir folder.."
    mkdir $bkp_dir
    if [ $? -ne 0 ]; then
        echo "$bkp_dir was not created, please check.."
    fi
else
    echo "$bkp_dir folder already exists.."
fi


# hostname
echo ""
echo "setting hostname and hosts record.."
cp $hostname_file $bkp_dir/hostname.orig
read -p "Enter desired hostname: " servername
hostnamectl set-hostname $servername
echo "$servername set as hostname - `hostname -s`"
cp $hosts_file $bkp_dir/hosts.orig
echo "`ip route get 1 | awk '{print $NF;exit}'` $servername" >> $hosts_file


# 'noatime' in fstab
echo ""
echo "setting 'noatime' mount option in $mounts_file.."
cp $mounts_file $bkp_dir/fstab.orig
sed -i '/swap*/! s/defaults/defaults,noatime/g' $mounts_file
echo ""
echo "remounting partitions listed in $mounts_file"
echo ""
for partition in $(df -hPT | grep -v tmpfs | grep -v swap | grep -v Mounted | awk '{print $7}'); do
    mount -o remount $partition
done


# yum
echo ""
echo "installing packages and performing os update"
yum install deltarpm epel-release -y
yum makecache fast
yum update -y
# remove any unwanted package(s)
yum install screen curl vim dos2unix lsof man tree zip unzip mlocate wget rsync chrony -y 
updatedb


# services
echo ""
echo "services: enabling chrony, disabling firewalld.."
systemctl enable chronyd # switch with 'disable' for inacvive chronyd
systemctl disable firewalld # switch with 'enable' for active firewalld


# selinux
echo ""
echo "disabling selinux.."
cp $selinux_file $bkp_dir/_selinux_config.orig
setenforce 0
# comment out the line below if you want to continue using selinux in enforcing mode
sed -i 's/^SELINUX=.*/SELINUX=disabled/g' $selinux_file && cat $selinux_file 


# timezone setup
echo ""
echo "setting timzone Europe/Sofia.."
timedatectl set-timezone Europe/Sofia # change timezone according to your needs


# ssh key generation 
echo ""
echo "generating ssh key for $USER.."
ssh-keygen -t rsa -b 2048 -N "" -f ~/.ssh/id_rsa
echo ""


# display basic system info
echo "Today's date is: `date`."
echo ""

# system name
echo "Hostname:"
hostname -f

# active users
echo "Active users:"
w | cut -d ' ' -f 1 | grep -v USER | sort -u
echo ""

# system information using uname command
echo "This is `uname -s` running on a `uname -m` CPU."
echo ""

# uptime
echo "Uptime is:"
uptime
echo ""

# free mem
echo "System memory info:"
echo "in GBs"
free -g
echo "in MBs"
free -m
echo ""

# disk usage
echo "Disk Space Utilization:"
df -mh
echo ""

# kernel and other info:
echo "Kernel:"
uname -a

# complete
sleep 1
echo ""
echo "completed, it is recommended to reboot your server.."
echo ""
