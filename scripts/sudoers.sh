#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

apt-get -y install sudo

# no tty
echo "Defaults !requiretty" >> /etc/sudoers
