#!/bin/bash

# rescan_scsi_added.sh

# Rescan scsi bus on your machine for newly added disks using this script
# Just execute ./rescan_scsi_added.sh and check the results
# Note that if you remove disks this script will still show them as present

# Revision:
# ver. 1.0.1 - Jul/21/2020
# ver. 1.0.0 - Jan/24.2018

# License: GPLv2
# https://github.com/kunchev/Linux-Shell-Scripts/blob/master/LICENSE.md

# Get block device list function:
list_blk() {
    local blklist=`lsblk`
    echo "----$1:"
    printf "%s\n" "${blklist}"
}

# Rescan scsi bus function - Linux, when adding a new disk:
rescan_scsi_bus_added() {
    local scsihost="/sys/class/scsi_host/host*/scan"
    for BUS in ${scsihost}
    do
        echo "- - -" >  ${BUS}
    done
}

function main() {
    clear
    list_blk "Current block devices"
    rescan_scsi_bus_added
    list_blk "Rescanned blk devs"
}


# run:
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root, exiting..!!" 1>&2
    exit 1
else
    main
fi
