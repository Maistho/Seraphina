#!/bin/bash
if [[ $UID != 0 ]]; then
    echo "Please run this script with sudo:"
    echo "sudo $0 $*"
    exit 1
fi
mkdir /usr/local/lib/seraphina
cp source/* /usr/local/lib/seraphina/
ln -s /usr/local/lib/seraphina/seraphina.rb /usr/local/bin/seraphina