#!/bin/bash

# rescan_scsi_added.sh

# Rescan scsi bus on your machine for newly added disks using this script
# Just execute ./rescan_scsi_added.sh and check the results

# Author: Petyo Kunchev
# Revision:
# ver.1.0 - 24.01.2018

# License: GPLv2

# Clear the screen:
clear

# Check if you are running this script under root privileges:
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root, exiting..!!" 1>&2
    exit 1
fi


# Get block device list:
list_blk() {
    local blklist=`lsblk`
    echo "----$1:"
    printf "%s\n" "${blklist}"
}

# Rescan scsi bus - Linux, when adding a new disc:
rescan_scsi_bus_added() {
    local scsihost="/sys/class/scsi_host/host*/scan"
    for BUS in ${scsihost}
    do
        echo "- - -" >  ${BUS}
    done
}

function main() {
    list_blk "Current blk devs"
    rescan_scsi_bus_added
    list_blk "Rescanned blk devs"
}

# Call main function:
main
