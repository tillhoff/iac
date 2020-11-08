#!/bin/bash

if [ "$HOSTNAME" != "bc-5f-f4-8b-19-ce" ]; then
  echo "Wrong hostname."
  exit
fi

# DATA-SSD pool
NAME="data-ssds"
DISKID="ata-Samsung*"
if sudo zpool status -v | grep $NAME >/dev/null; then
  DISKS=$(ls /dev/disk/by-id/$DISKID)
  for DISK in ${DISKS[@]}; do sudo sgdisk --zap-all $DISK; done # clear all partitions from disks
  DISKS=$(ls /dev/disk/by-id/$DISKID)
  sudo zpool create -m /mnt/$NAME -f $NAME raidz ${DISKS[*]} # create pool
  sudo chown enforge:enforge /mnt/$NAME #  set permission on mount folder
fi

NAME="data-hdds"
DISKID="ata-WDC*"
if sudo zpool status -v | grep $NAME >/dev/null; then
  DISKS=$(ls /dev/disk/by-id/$DISKID)
  for DISK in ${DISKS[@]}; do sudo sgdisk --zap-all $DISK; done # clear all partitions from disks
  DISKS=$(ls /dev/disk/by-id/$DISKID)
  sudo zpool create -m /mnt/$NAME -f $NAME raidz ${DISKS[*]} # create pool
  sudo chown enforge:enforge /mnt/$NAME #  set permission on mount folder
fi

sudo zpool status -v
