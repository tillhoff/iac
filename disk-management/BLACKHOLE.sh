#!/bin/bash

if [ "$HOSTNAME" != "BLACKHOLE" ]; then
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

ALLDISKS=$(ls "/dev/sd*")
for DISK in ${ALLDISKS[@]}; do
  if [[ "$(cat /sys/block/$DISK/queue/rotational)" == "1" ]]; then
    sudo hdparm -S 120 /dev/$DISK # set disk timeout to 10min (lookup calculation when adjusting!)
  fi
done
