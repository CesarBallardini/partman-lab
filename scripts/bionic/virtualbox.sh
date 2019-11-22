#!/bin/bash -x

SSH_USER=${SSH_USERNAME:-vagrant}
VBOX_VERSION=$(cat /home/${SSH_USER}/.vbox_version)

echo $VBOX_VERSION es la version a buscar
ls -lha /home/${SSH_USER}
sleep 10

mkdir /mnt/vb
mount -r -o loop /home/${SSH_USER}/VBoxGuestAdditions_${VBOX_VERSION}.iso /mnt/vb
yes | sh /mnt/vb/VBoxLinuxAdditions.run
umount /mnt/vb
rm /home/${SSH_USER}/VBoxGuestAdditions_${VBOX_VERSION}.iso
rm /home/${SSH_USER}/.vbox_version
