#!/bin/bash



# About: rescan_scsi_added.sh
#
# Rescan scsi bus on your machine for newly added disks using this script
# Just execute ./rescan_scsi_added.sh and check the results
# Note that if you remove disks this script will still show them as present

# Version log:
# ver. 1.0.1 - Jul/21/2020
# ver. 1.0.0 - Jan/24.2018

# License: GPLv2


function list_blk() {
    # Get block device list function - Linux, current block devices
    local blklist=$(lsblk)
    echo "----$1:"
    printf "%s\n" "${blklist}"
    echo ""
}

function rescan_scsi_bus_added() {
    # Rescan scsi bus function - Linux, when adding a new disk
    local scsihost="/sys/class/scsi_host/host*/scan"
    for BUS in ${scsihost}
    do
        echo "- - -" >  ${BUS}
    done
}

function main() {
    # Clear screen and call the list_blk() and rescan_blk() functions 
    clear
    list_blk "Current block devices on $(hostname -s)"
    echo -e "scanning...\n"
    rescan_scsi_bus_added
    list_blk "Rescanned block devices on $(hostname -s)"
}


# check if running as root and call main() if so, else exit
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root, you are $(whoami), exiting..!!" 1>&2
    exit 1
else
    main
fi
