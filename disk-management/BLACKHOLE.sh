#!/bin/bash

if [ "$HOSTNAME.sh" != "${0##*/}" ]; then
  <&2 echo "Wrong hostname."
  exit
fi
if [[ $EUID -eq 0 ]]; then
  <&2 echo "You mustn't run this script as root."
  exit
fi

# DATA-SSD pool
NAME="data-ssds"
DISKID="ata-Samsung*"
printf "Started working on pool $NAME.\n"
if ! sudo zpool status -v | grep $NAME >/dev/null; then
  DISKS=$(ls /dev/disk/by-id/$DISKID)
  for DISK in ${DISKS[@]}; do sudo sgdisk --zap-all $DISK; done # clear all partitions from disks
  DISKS=$(ls /dev/disk/by-id/$DISKID)
  sudo rm -fr /mnt/$NAME
  sudo zpool create -m /mnt/$NAME -f $NAME raidz ${DISKS[*]} # create pool
  sudo chown enforge:enforge /mnt/$NAME #  set permission on mount folder
else
  printf "Nothing to do.\n"
fi
printf "Finished working on pool $NAME.\n"

NAME="data-hdds"
DISKID="ata-WDC*"
printf "Started working on pool $NAME.\n"
if ! sudo zpool status -v | grep $NAME >/dev/null; then
  DISKS=$(ls /dev/disk/by-id/$DISKID)
  for DISK in ${DISKS[@]}; do sudo sgdisk --zap-all $DISK; done # clear all partitions from disks
  DISKS=$(ls /dev/disk/by-id/$DISKID)
  sudo rm -fr /mnt/$NAME
  sudo zpool create -m /mnt/$NAME -f $NAME raidz ${DISKS[*]} # create pool
  sudo chown enforge:enforge /mnt/$NAME #  set permission on mount folder
else
  printf "Nothing to do.\n"
fi
printf "Finished working on pool $NAME.\n"

sudo zpool status -v

printf "Started setting spin-down timeout (on rotating disks only).\n"
ALLDISKS=$(ls /dev/sd?)
for DISK in ${ALLDISKS[@]}; do
  if [[ "$(cat /sys/block/${DISK#/dev/}/queue/rotational)" == "1" ]]; then
    sudo hdparm -S 242 $DISK # set disk timeout to 1h (lookup calculation when adjusting!)
  fi
done
printf "Finished setting spin-down timeout.\n"
