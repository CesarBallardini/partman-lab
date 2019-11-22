#!/bin/bash

SSH_USER=${SSH_USERNAME:-vagrant}

export DEBIAN_FRONTEND=noninteractive

paquetes_innecesarios= "ppp pppconfig pppoeconf popularity-contest installation-report landscape-common wireless-tools wpasupplicant ubuntu-serverguide"


# ELiminamos paquetes que no aportan para una vm
[ $(lsb_release -is) == "Debian" ] && apt-get -y purge crda bluetooth wpasupplicant wireless-regdb wireless-tools bluez eject iw laptop-detect task-laptop powertop
apt-get -y purge $paquetes_innecesarios


# Removing all linux kernels except the currrent one
dpkg --list | awk '{ print $2 }' | grep 'linux-image-*-generic' | grep -v $(uname -r) | xargs apt-get -y purge

# Removing linux source
dpkg --list | awk '{ print $2 }' | grep linux-source | xargs apt-get -y purge

# Removing development packages
dpkg --list | awk '{ print $2 }' | grep -- '-dev$' | xargs apt-get -y purge

# Removing documentation
dpkg --list | awk '{ print $2 }' | grep -- '-doc$' | xargs apt-get -y purge

# Removing development tools
#dpkg --list | grep -i compiler | awk '{ print $2 }' | xargs apt-get -y purge
#apt-get -y purge cpp gcc g++
apt-get -y purge build-essential git

# Clean up
apt-get -y --purge remove linux-headers-$(uname -r) build-essential
apt-get -y purge $(dpkg --list |grep '^rc' |awk '{print $2}')


# Eliminamos kernels que no están en uso 
apt-get -y purge $(dpkg --list |egrep 'linux-image-[0-9]' |awk '{print $3,$2}' |sort -nr |tail -n +2 |grep -v $(uname -r) |awk '{ print $2}')

# Cleanup apt cache
apt-get -y --purge autoremove
apt-get -y clean
apt-get -y autoclean



# Clean up orphaned packages with deborphan
apt-get -y install deborphan
while [ -n "$(deborphan --guess-all --libdevel)" ]; do
    deborphan --guess-all --libdevel | xargs apt-get -y purge
done
apt-get -y purge deborphan dialog

# Removing man pages"
#rm -rf /usr/share/man/*

# Removing APT files"
#find /var/lib/apt -type f | xargs rm -f

# Removing any docs"
#rm -rf /usr/share/doc/*

# Removing caches"
find /var/cache -type f -exec rm -rf {} \;


# Installed packages
dpkg --get-selections | grep -v deinstall

# Cleaning up udev rules
rm -rf /dev/.udev/
rm /lib/udev/rules.d/75-persistent-net-generator.rules

# Cleaning up leftover dhcp leases
[ -d "/var/lib/dhcp3" ] && rm /var/lib/dhcp3/*
[ -d "/var/lib/dhcp" ]  && rm /var/lib/dhcp/*


# from https://github.com/cbednarski/packer-ubuntu/blob/master/scripts-1604/vm_cleanup.sh#L9-L15
# When booting with Vagrant / VMware the PCI slot is changed from 33 to 32.
# Instead of eth0 the interface is now called ens33 to mach the PCI slot,
# so we need to change the networking scripts to enable the correct
# interface.
#
# NOTE: After the machine is rebooted Packer will not be able to reconnect
# (Vagrant will be able to) so make sure this is done in your final
# provisioner.
sed -i "s/ens33/ens32/g" /etc/network/interfaces


# Add delay to prevent "vagrant reload" from failing
echo "pre-up sleep 2" >> /etc/network/interfaces

# Cleaning up tmp
rm -rf /tmp/*

# Remove Bash history
unset HISTFILE
rm -f /root/.bash_history
rm -f /home/${SSH_USER}/.bash_history

# Clean up log files
find /var/log -type f | while read f; do echo -ne '' > "${f}"; done;

# Clearing last login information
>/var/log/lastlog
>/var/log/wtmp
>/var/log/btmp



# Whiteout root
count=$(df --sync -kP / | tail -n1  | awk -F ' ' '{print $4}')
let count--
dd if=/dev/zero of=/tmp/whitespace bs=1024 count=$count
rm /tmp/whitespace

# Whiteout /boot
count=$(df --sync -kP /boot | tail -n1 | awk -F ' ' '{print $4}')
let count--
dd if=/dev/zero of=/boot/whitespace bs=1024 count=$count
rm /boot/whitespace


set +e
swapuuid=$(/sbin/blkid -o value -l -s UUID -t TYPE=swap)
case "$?" in
    2|0) ;;
    *) exit 1 ;;
esac
set -e
if [ "x${swapuuid}" != "x" ]; then
    # Whiteout the swap partition to reduce box size
    # Swap is disabled till reboot
    swappart=$(readlink -f /dev/disk/by-uuid/$swapuuid)
    /sbin/swapoff "${swappart}"
    dd if=/dev/zero of="${swappart}" bs=1M || echo "dd exit code $? is suppressed"
    /sbin/mkswap -U "${swapuuid}" "${swappart}"
fi

dd if=/dev/zero of=/EMPTY bs=1M  || echo "dd exit code $? is suppressed"
rm -f /EMPTY


# Block until the empty file has been removed, otherwise, Packer
# will try to kill the box while the disk is still full and that's bad
# sync data to disk (fix packer)
sync
