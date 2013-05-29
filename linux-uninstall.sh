#!/bin/bash
if [[ $UID != 0 ]]; then
    echo "Please run this script with sudo:"
    echo "sudo $0 $*"
    exit 1
fi
rm /usr/local/bin/seraphina
rm -rf /usr/local/lib/seraphina/