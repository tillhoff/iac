#!/bin/bash

if [ "$HOSTNAME.sh" != "${0##*/}" ]; then
  echo "Wrong hostname."
  exit
fi
if [[ $EUID -eq 0 ]]; then
  <&2 echo "You mustn't run this script as root."
  exit
fi

# windows machines
#   windows machines need to backup via push. A) because they are probably not online at the backup timeslot and B) because its harder to ssh into them them from them.
foreach machine ( blackstone baby )
  username=blackstone
  sudo useradd --create-home $username
  sudo usermod -a -G sshusers $username
  sudo runuser -l $username -c "ssh-keygen -t ed25519 -C \"$USER@$(hostname)\""
  mkdir -p /mnt/data-hdds/backup/$username/
  chown -R $username /mnt/data-hdds/backup/$username
  printf "%s\n" \
    "To retrieve your machines key, please run" \
    "rsync $username@$(hostname):~/.ssh/id_ed25519 ~/.ssh/id_ed25519" \
    "on your (wsl2) console."
  printf "%s\n" \
    "To schedule the backup on your machine, run the following commands in an elevated powershell:" \
    "Import-Module TaskScheduler \$task = New-Task"
    "\$task.Settings.Hidden = \$true" \
    "Add-TaskAction -Task \$task -Path C:\Windows\System32\wsl.exe –Arguments \"rsync -zaP -e 'ssh -i $HOME/.ssh/id_ed25519' /mnt/d \$(hostname)@$(hostname):/mnt/data-hdds/backup/\$(hostname)/\"" \
    "Add-TaskTrigger -Task \$task -Weekly -At '04:00'" \
    "Register-ScheduledJob –Name \"Backup D: to $(hostname)\" -Task \$task"
end

# # linux machines
# foreach machine ( a.enforge.de )
#   # do this only when at least one linux machine is given
#   if [ ! -f ~/.ssh/id_ed25519 ]; then
#     printf "%s\n" \
#       "Please add your private key to this host, so it can use it for backups:" \
#       "rsync ~/.ssh/id_ed25519 $USER@$(hostname):~/.ssh/id_ed25519"
#     read -p "Press enter to continue..."

#   fi
#   mkdir -p /mnt/data-hdds/backup/$machine/
#   if [ ! -f ~/.config/systemd/user/backup-$machine.service ]; then
#     printf "%s\n" \
#       "[Unit]" \
#       "Description=Backup $machine to /mnt/data-hdds/backup/$machine/" \
#       "" \
#       "[Service]" \
#       "ExecStart=" \
#       "" \
#       "[Install]" \
#       "WantedBy=multi-user.target" \
#       > ~/.config/systemd/user/backup-$machine.service
#   fi
#   if [ ! -f ~/.config/systemd/user/backup-$machine.timer ]; then
#     printf "%s\n" \
#       "[Unit]" \
#       "Description=Start backup of $machine on a regular base" \
#       "" \
#       "[Timer]" \
#       "OnCalendar=Sun 04:00" \
#       "Persistent=false # if set on true, trigger if last start time was missed" \
#       "" \
#       "[Install]" \
#       "WantedBy=timers.target" \
#       > ~/.config/systemd/user/backup-$machine.timer
#   fi
# end
