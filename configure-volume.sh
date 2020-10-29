#!/bin/bash

if [[ $EUID != 0 ]]; then
  <&2 echo "You're not root. This script isn't meant for that."
  exit
fi

devvolumename="HC_Volume_6753628"
mntvolumename="volume"

mkdir -p /mnt/$mntvolumename

mount -o discard,defaults /dev/disk/by-id/scsi-0$devvolumename /mnt/$mntvolumename || true

if [ "$(cat /etc/fstab | grep $devvolumename)" == "" ]; then
  echo "/dev/disk/by-id/scsi-0$devvolumename /mnt/$mntvolumename ext4 discard,nofail,defaults 0 0" >> /etc/fstab
fi
