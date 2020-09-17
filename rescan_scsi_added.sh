#!/bin/bash

# rescan_scsi_added.sh
#
# Rescan scsi bus on your machine for newly added disks using this script
# Just execute ./rescan_scsi_added.sh and check the results
# Note that if you remove disks this script will still show them as present


function list_blk {
    # get block device list function - Linux, current block devices
    local blklist=$(lsblk)
    echo "----$1:"
    printf "%s\n" "${blklist}"
    echo ""
}

function rescan_scsi_bus_added {
    # rescan scsi bus function - Linux, when adding a new disk
    local scsihost="/sys/class/scsi_host/host*/scan"
    for BUS in ${scsihost}
    do
        echo "- - -" >  ${BUS}
    done
}


function main {
    # clear screen and call the list_blk() and rescan_blk() functions: 
    clear
    list_blk "Current block devices on $(hostname -s)"
    echo -e "scanning...\n"
    rescan_scsi_bus_added
    list_blk "Rescanned block devices on $(hostname -s)"
}

# check if the script is running as root/sudo user and call main() if so, else exit:
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root, you are $(whoami), exiting..!!" 1>&2
    exit 1
else
    main
fi
