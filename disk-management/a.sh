#!/bin/bash

if [ "$HOSTNAME.sh" != "${0##*/}" ]; then
  <&2 echo "Wrong hostname."
  exit
fi
if [[ $EUID -eq 0 ]]; then
  <&2 echo "You mustn't run this script as root."
  exit
fi

# volume pool
NAME="volume"
DISKID="scsi-0HC_Volume_*"
printf "Started working on pool $NAME.\n"
if ! sudo zpool status -v | grep $NAME >/dev/null; then
  DISKS=$(ls /dev/disk/by-id/$DISKID)
  for DISK in ${DISKS[@]}; do sudo sgdisk --zap-all $DISK; done # clear all partitions from disks
  DISKS=$(ls /dev/disk/by-id/$DISKID)
  sudo rm -fr /mnt/$NAME
  sudo zpool create -m /mnt/$NAME -f $NAME ${DISKS[*]} # create pool
  sudo chown enforge:enforge /mnt/$NAME #  set permission on mount folder
else
  printf "Nothing to do.\n"
fi
printf "Finished working on pool $NAME.\n"

sudo zpool status -v
