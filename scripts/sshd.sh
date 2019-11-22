#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

apt-get -y install openssh-server
echo "UseDNS no" >> /etc/ssh/sshd_config
echo "GSSAPIAuthentication no" >> /etc/ssh/sshd_config
