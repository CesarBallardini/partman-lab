#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
export DEBIAN_PRIORITY=critical

apt-get update
apt-get -y install curl
exit 0

apt-get -q -y \
     -o "Dpkg::Options::=--force-confdef" \
     -o "Dpkg::Options::=--force-confold" \
     upgrade

apt-get -y autoremove
apt-get -y dist-upgrade
apt-get -y autoremove
apt-get -y autoclean

# install curl to fix broken wget while retrieving content from secured sites
apt-get -y install curl
